const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// Customers can't write to promos, so usage is counted here. Only the
// top-level orders/{orderId} doc is watched, not its mirror under
// users/{uid}/orders/{orderId}, which would double-count.
exports.onOrderPromoUsed = onDocumentCreated(
    "orders/{orderId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;

      const metadata = snap.data().metadata;
      const code = metadata && metadata.promo_code;
      if (!code) return;

      const db = admin.firestore();
      const promos = await db.collection("promos")
          .where("code", "==", code)
          .limit(1)
          .get();

      if (promos.empty) {
        console.warn(`Order ${event.params.orderId} used unknown promo.`);
        return;
      }

      await promos.docs[0].ref.update({
        usedCount: admin.firestore.FieldValue.increment(1),
        updatedAt: Date.now(),
      });
    },
);
