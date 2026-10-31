const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const {assertStaff} = require("./require_staff");

// sendEachForMulticast rejects more tokens than this in one call.
const FCM_BATCH_SIZE = 500;

/**
 * Mirrors PromoModel.discountLabel in the admin app. The fixed amount comes
 * first because that is what the customer app applies when a promo has both.
 * @param {object} promo The promo document data.
 * @return {string} A short description of the discount.
 */
function discountLabel(promo) {
  if (promo.discountAmount > 0) {
    return `$${promo.discountAmount.toFixed(2)} off`;
  }
  if (promo.discountPercentage > 0) {
    return `Up to ${Math.trunc(promo.discountPercentage)}% off`;
  }
  return "Special offer";
}

/**
 * Mirrors PromoModel.isCurrentlyActive in the admin app.
 * @param {object} promo The promo document data.
 * @return {boolean} Whether customers can use the promo right now.
 */
function isCurrentlyActive(promo) {
  const now = Date.now();
  const limit = promo.usageLimit || 0;
  return promo.isActive === true &&
    now > promo.startDate &&
    now < promo.endDate &&
    (limit === 0 || (promo.usedCount || 0) < limit);
}

/**
 * Builds the FCM message. The image is what makes it a big notification:
 * Android shows it expanded, and iOS needs mutableContent plus a Notification
 * Service Extension in the customer app to download it.
 * @param {string[]} tokens Up to FCM_BATCH_SIZE device tokens.
 * @param {object} content Message title, body, image, promo id and code.
 * @return {object} A multicast message.
 */
function buildMessage(tokens, {title, body, imageUrl, promoId, code}) {
  return {
    tokens,
    notification: {title, body, ...(imageUrl && {imageUrl})},
    data: {promoId, code, type: "promo"},
    android: {
      notification: {
        sound: "default",
        channelId: "high_importance_channel",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          mutableContent: true,
        },
      },
      ...(imageUrl && {fcmOptions: {imageUrl}}),
    },
  };
}

exports.sendPromoNotification = onCall(
    {timeoutSeconds: 300},
    async (request) => {
      await assertStaff(request);

      const promoId = request.data && request.data.promoId;
      if (typeof promoId !== "string" || !promoId) {
        throw new HttpsError("invalid-argument", "promoId is required.");
      }

      const db = admin.firestore();
      const promoSnap = await db.collection("promos").doc(promoId).get();
      if (!promoSnap.exists) {
        throw new HttpsError("not-found", "Promo not found.");
      }

      const promo = promoSnap.data();
      if (!isCurrentlyActive(promo)) {
        throw new HttpsError(
            "failed-precondition",
            "Only active promos can be sent.",
        );
      }

      const title = `${promo.title}: ${discountLabel(promo)}`;
      const body = `Use code ${promo.code} at checkout.`;
      const imageUrl = promo.imageUrl || "";

      // 1. Add to every user's in-app notifications
      const usersSnapshot = await db.collection("users").select().get();
      const writer = db.bulkWriter();
      for (const userDoc of usersSnapshot.docs) {
        writer.create(userDoc.ref.collection("notifications").doc(), {
          title,
          message: body,
          promoId,
          imageUrl,
          endDate: promo.endDate,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
          type: "promo",
          metadata: {code: promo.code},
        });
      }
      await writer.close();

      // 2. Collect tokens, one entry per device even if it has two accounts
      const tokensSnapshot = await db.collectionGroup("fcmTokens").get();
      const tokenRefs = new Map();
      for (const tokenDoc of tokensSnapshot.docs) {
        const token = tokenDoc.data().token;
        if (!token) continue;
        tokenRefs.set(token, [...(tokenRefs.get(token) || []), tokenDoc.ref]);
      }

      const tokens = [...tokenRefs.keys()];
      let successCount = 0;
      let failureCount = 0;
      const staleDeletePromises = [];

      // 3. Send in batches and clean up stale/invalid tokens
      for (let i = 0; i < tokens.length; i += FCM_BATCH_SIZE) {
        const batch = tokens.slice(i, i + FCM_BATCH_SIZE);
        const response = await admin.messaging().sendEachForMulticast(
            buildMessage(batch, {
              title,
              body,
              imageUrl,
              promoId,
              code: promo.code,
            }),
        );

        successCount += response.successCount;
        failureCount += response.failureCount;

        response.responses.forEach((resp, idx) => {
          if (
            !resp.success &&
            resp.error &&
            (resp.error.code ===
              "messaging/registration-token-not-registered" ||
              resp.error.code === "messaging/invalid-registration-token")
          ) {
            for (const ref of tokenRefs.get(batch[idx])) {
              staleDeletePromises.push(ref.delete());
            }
          }
        });
      }

      await Promise.all(staleDeletePromises);

      console.log(
          `Promo ${promoId}: ${successCount} sent, ${failureCount} failed, ` +
          `${usersSnapshot.size} in-app notifications.`,
      );

      return {
        success: true,
        successCount,
        failureCount,
        userCount: usersSnapshot.size,
      };
    },
);
