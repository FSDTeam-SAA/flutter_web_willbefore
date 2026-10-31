const {HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

const STAFF_ROLES = ["admin", "super_admin"];

/**
 * Throws unless the callable request comes from an admin or super admin.
 * @param {object} request The onCall request.
 * @return {Promise<void>}
 */
async function assertStaff(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  const callerSnap = await admin.firestore()
      .collection("users").doc(request.auth.uid).get();
  const callerRole = callerSnap.exists ? callerSnap.data().role : null;

  if (!STAFF_ROLES.includes(callerRole)) {
    throw new HttpsError(
        "permission-denied",
        "Only admins can send notifications.",
    );
  }
}

module.exports = {assertStaff};
