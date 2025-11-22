const {setGlobalOptions} = require("firebase-functions/v2");
const {
  onRequest,
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
setGlobalOptions({maxInstances: 10});
exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});
admin.initializeApp();
exports.inviteUser = onCall(async (data, context) => {
  console.log("Data : ", data.data.email);
  if (!data.auth) {
    throw new HttpsError(
        "permission-denied",
        "Only admins can invite new users.",
    );
  }
  const email = data.data.email;
  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: "123456",
    });
    await admin.auth().generatePasswordResetLink(email);
    return {success: true, uid: userRecord.uid};
  } catch (error) {
    throw new HttpsError("unknown-error", error.message);
  }
});
exports.startShipment = onCall(async (params, context) => {
  const {fcmToken, orderId, msg, title} = params.data;
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


