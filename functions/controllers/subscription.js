const {onCall} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

exports.sendSubscriptionNotification = onCall(async (request) => {
  try {
    const response = await admin.messaging().send({
      topic: "all_users",
      notification: {
        title: "Breaking News!",
        body: "Something happened...",
      },
      data: {
        type: "news",
        id: "456",
      },
    });
    return {success: true, response};
  } catch (error) {
    console.error("Error sending message:", error);
    return {success: false, error: error.message};
  }
});
