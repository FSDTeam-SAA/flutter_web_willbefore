const {onCall} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

exports.startShipment = onCall(async (request) => {
  const {userId, fcmToken, orderId, msg, title} = request.data;
  const db = admin.firestore();

  // 1. Collect tokens
  let tokens = [];

  // Legacy support: single token passed directly
  if (fcmToken) {
    tokens.push(fcmToken);
  }

  // New support: fetch all tokens from subcollection
  if (userId) {
    try {
      const tokensSnap = await db
          .collection("users")
          .doc(userId)
          .collection("fcmTokens")
          .get();

      tokensSnap.docs.forEach((doc) => {
        const data = doc.data();
        if (data.token) tokens.push(data.token);
      });
    } catch (e) {
      console.error("Error fetching tokens for user:", userId, e);
    }
  }

  // Deduplicate tokens
  tokens = [...new Set(tokens)];

  if (tokens.length === 0) {
    console.log("No tokens found for user/request");
    return {success: false, message: "No tokens found"};
  }

  // 2. Prepare message
  const notificationTitle = title || "Orders Shipped";
  const notificationBody = msg || `Your order #${orderId} has been shipped.`;

  // Construct message payload
  const message = {
    tokens: tokens,
    notification: {
      title: notificationTitle,
      body: notificationBody,
    },
    data: {
      orderId: orderId || "",
      type: "shipment_started",
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
    android: {
      priority: "high",
      notification: {
        sound: "default",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  // 3. Send
  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(
        "Notifications sent:",
        response.successCount,
        "successful,",
        response.failureCount,
        "failed",
    );

    // Clean up invalid tokens
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
        }
      });
      console.log("Failed tokens to potentially remove:", failedTokens);
    }

    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    console.error("Error sending multicast message:", error);
    return {success: false, error: error.message};
  }
});
