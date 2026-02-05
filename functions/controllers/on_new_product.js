const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

exports.onNewProduct = onDocumentCreated(
    "products/{productId}",
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) {
        console.log("No data associated with the event");
        return;
      }

      const productData = snapshot.data();
      const productName = productData.title || "New Product";
      const productPrice = productData.actualPrice || "";
      const db = admin.firestore();

      console.log(
          `New product created: ${productName}. Fetching all user tokens...`,
      );

      // 1. Get all users
      const usersSnap = await db.collection("users").get();
      const tokens = [];

      // 2. Collect tokens from each user's fcmTokens subcollection
      // Note: This could be optimized for many users
      const tokenFetchPromises = usersSnap.docs.map(async (userDoc) => {
        const tokensSubSnap = await userDoc.ref.collection("fcmTokens").get();
        tokensSubSnap.docs.forEach((tokenDoc) => {
          const data = tokenDoc.data();
          if (data.token) {
            tokens.push(data.token);
          }
        });
      });

      await Promise.all(tokenFetchPromises);

      // Deduplicate tokens
      const uniqueTokens = [...new Set(tokens)];

      if (uniqueTokens.length === 0) {
        console.log("No tokens found to notify.");
        return;
      }

      // 3. Prepare message
      const message = {
        tokens: uniqueTokens,
        notification: {
          title: "New Product Alert! 🚀",
          body: `Check out our new arrival: ${productName}${
          productPrice ? ` for only $${productPrice}` : ""
          }!`,
        },
        data: {
          productId: event.params.productId,
          type: "new_product",
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

      // 4. Send
      try {
        const response = await admin.messaging().sendEachForMulticast(message);
        console.log(
            "Product notifications sent:",
            response.successCount,
            "successful,",
            response.failureCount,
            "failed",
        );

        // Optional: Clean up failed tokens if needed
        return response;
      } catch (error) {
        console.error("Error sending multicast notification:", error);
        return null;
      }
    },
);
