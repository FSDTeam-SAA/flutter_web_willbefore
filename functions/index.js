/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 */

const {setGlobalOptions} = require("firebase-functions");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Limit max instances
setGlobalOptions({maxInstances: 10});

/**
 * Start Shipment Notification Function
 */
exports.startShipment = functions.https.onCall((data, context) => {
  const fcmToken = data.fcmToken;
  const orderId = data.orderId;

  console.log("JS : ", orderId);

  return admin.messaging().send({
    token: fcmToken,
    notification: {
      title: "Shipment Started 🚚",
      body: `Your order #${orderId} is on the way.`,
    },
    data: {
      orderId: String(orderId),
      type: "shipment_start",
    },
  });
});
