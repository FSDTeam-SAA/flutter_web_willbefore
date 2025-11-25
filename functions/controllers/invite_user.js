const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

exports.inviteUser = onCall(async (request, context) => {
  console.log("Data : ", request.data.email);
  if (!request.auth) {
    throw new HttpsError(
        "permission-denied",
        "Only admins can invite new users.",
    );
  }
  const email = request.data.email;
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
