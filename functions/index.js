/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { setGlobalOptions } = require("firebase-functions/v2");
const {
  onRequest,
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const admin = require("firebase-admin");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});

admin.initializeApp();

exports.inviteUser = onCall(async (data, context) => {
  // 1️⃣ Only allow admins to call this function

  console.log("Data : ", data.data.email);
  if (!data.auth) {
    throw new HttpsError(
      "permission-denied",
      "Only admins can invite new users."
    );
  }

  const email = data.data.email;

  console.log(">>> INVITE USER EMAIL:", email);

  try {
    // 2️⃣ Create user without password
    const userRecord = await admin.auth().createUser({
      email: email,
      password: "123456",
    });

    // 3️⃣ Send password reset email (this lets the user set their password)
    await admin.auth().generatePasswordResetLink(email);

    return { success: true, uid: userRecord.uid };
  } catch (error) {
    throw new HttpsError("unknown-error", error.message);
  }
});

exports.startShipment = onCall(async (params, context) => {
  const { fcmToken, orderId, msg, title } = params.data;

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

// exports.makeMeAdmin = onCall(async (data, context) => {
// //   console.log("Data : ", data);
//   console.log("Full context object:", context);
//   console.log("context.auth:", data.auth.uid);
//   console.log("context.auth?.uid:", context.auth?.uid);
//   // 1. First check if user is logged in at all
//   if (!data.auth || !data.auth.uid) {
//     throw new HttpsError("unauthenticated", "You must be logged in.");
//   }

//   // 2. Now safely compare the UID
//   if (data.auth.uid !== "6w2x5GLzsMcb46DQAjA61ig07Pv2") {
//     throw new HttpsError("permission-denied", "Nope – wrong user.");
//   }

//   // 3. Set admin claim
//   await admin.auth().setCustomUserClaims(data.auth.uid, { admin: true });

//   return { message: "You are now admin! Please sign out and sign in again." };
// });
