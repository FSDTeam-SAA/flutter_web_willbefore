const {onCall} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

exports.startShipment = onCall(async (params, context) => {
  const {fcmToken, orderId, msg, title} = params.data;
  // await startShipment({fcmToken, orderId, msg, title});
  const message = {
    token: fcmToken,
    notification: {
      title: title,
      body: msg,
    },
    data: {
      orderId: orderId,
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
  try {
    const response = await admin.messaging().send(message);
    console.log("Successfully sent message:", response);
  } catch (error) {
    console.log("Error sending message:", error);

    if (error.code === "messaging/registration-token-not-registered") {
      console.log("Token is invalid or expired");
    }
  }
});
