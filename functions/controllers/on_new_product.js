const {onCall} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

exports.sendProductNotification = onCall(async (request) => {
  const product = request.data;

  if (!product || !product.name) {
    console.error("Invalid product data received");
    return {success: false, error: "Invalid product data"};
  }

  console.log(
      "Fetching all FCM tokens for product notification: " +
      `${product.name}...`,
  );

  // 1. Collect all FCM tokens from every user's fcmTokens subcollection
  const db = admin.firestore();
  const usersSnapshot = await db.collection("users").get();

  const tokens = [];
  const tokenDocRefs = []; // track refs for stale token cleanup
  const notificationPromises = []; // track Firestore notification writes

  for (const userDoc of usersSnapshot.docs) {
    // 1a. Add to user's notifications collection in Firestore
    notificationPromises.push(
        userDoc.ref.collection("notifications").add({
          title: `New Product: ${product.name}!`,
          message: product.shortDescription || "",
          productId: product.id || "",
          imageUrl: product.imageUrl || "",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
          type: "new_product",
        }),
    );

    // 1b. Collect FCM tokens
    const tokensSnapshot = await userDoc.ref.collection("fcmTokens").get();
    for (const tokenDoc of tokensSnapshot.docs) {
      const data = tokenDoc.data();
      if (data.token) {
        tokens.push(data.token);
        tokenDocRefs.push(tokenDoc.ref);
      }
    }
  }

  // Await all notification writes (in parallel with FCM processing)
  if (notificationPromises.length > 0) {
    await Promise.all(notificationPromises);
    console.log(`Added notifications to ${notificationPromises.length} users.`);
  }

  if (tokens.length === 0) {
    console.log("No FCM tokens found. No notifications sent.");
    return {success: true, message: "No tokens registered"};
  }

  console.log(`Found ${tokens.length} token(s). Sending notifications...`);

  // 2. Build and send the multicast message
  const message = {
    tokens,
    notification: {
      title: `New Product: ${product.name}!`,
      body: product.shortDescription || "",
      imageUrl: product.imageUrl || "",
    },
    data: {
      productId: product.id || "",
      type: "new_product",
    },
    android: {
      notification: {
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },
  };

  const batchResponse = await admin.messaging().sendEachForMulticast(message);

  console.log(
      `${batchResponse.successCount} sent, ` +
      `${batchResponse.failureCount} failed.`,
  );

  // 3. Clean up stale/invalid tokens automatically
  const staleDeletePromises = [];
  batchResponse.responses.forEach((resp, idx) => {
    if (
      !resp.success &&
      resp.error &&
      (resp.error.code === "messaging/registration-token-not-registered" ||
        resp.error.code === "messaging/invalid-registration-token")
    ) {
      console.log(`Removing stale token at index ${idx}`);
      staleDeletePromises.push(tokenDocRefs[idx].delete());
    }
  });

  if (staleDeletePromises.length > 0) {
    await Promise.all(staleDeletePromises);
    console.log(`Cleaned up ${staleDeletePromises.length} stale token(s).`);
  }

  return {
    success: true,
    successCount: batchResponse.successCount,
    failureCount: batchResponse.failureCount,
  };
});
