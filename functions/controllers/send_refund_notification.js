const {onCall} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Reuse or create a generic notification sender
exports.sendRefundNotification = onCall(async (request) => {
  const {fcmToken, orderId, customerName, totalAmount} = request.data;
  console.log("Send Refund Notification : ", request.data);

  if (!fcmToken) {
    console.log("No FCM token provided");
    return {success: false, error: "No FCM token"};
  }

  const title = "Refund Processed";
  const body = `Hi ${customerName.split(" ")[0]}, 
  your order #${orderId.substring(
      0,
      8,
  )} has been fully refunded ($${parseFloat(totalAmount).toFixed(2)}).`;

  const message = {
    token: fcmToken,
    notification: {
      title,
      body,
    },
    data: {
      orderId,
      type: "refund_processed",
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
    android: {
      priority: "high",
      notification: {
        sound: "default",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        channelId: "orders", // make sure you have this channel
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
          category: "ORDER_CATEGORY",
        },
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Refund notification sent:", response);
    return {success: true, messageId: response};
  } catch (error) {
    console.error("Error sending refund notification:", error);

    if (error.code === "messaging/registration-token-not-registered") {
      console.log("FCM token expired or invalid");
      // Optionally: remove invalid token from user doc
    }
    return {success: false, error: error.message};
  }
});
