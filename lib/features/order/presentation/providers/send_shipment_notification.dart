import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutx_core/core/debug_print.dart';

Future<void> sendShipmentNotification({
  required String orderId,
  required String userId,
}) async {
  // 1. Get user's FCM token from Firestore
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  if (!userDoc.exists) {
    DPrint.warn("User document not found: $userId");
    return;
  }

  // final fcmToken = userDoc.data()?['fcmToken'] as String?;
  final fcmToken =
      "f_8iGeB9xUVxsG83yd1FQV:APA91bE5CM1Oo04P6JtExoc3XMnbjwUKmYOqanAnFSzGrLgVOuo6W0PMfG0Hk_K_5593ganexCc0DjBV11ZxWNuP3PYWljx3Tot6WUqgGksuzvtR8qzoMEM";

  if (fcmToken.isEmpty) {
    DPrint.warn("No FCM token found for user: $userId");
    return;
  }

  final callable = FirebaseFunctions.instance.httpsCallable(
    "startShipment",
    options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
  );

  try {
    await callable.call({"fcmToken": fcmToken, "orderId": orderId});
    DPrint.log("Push notification sent successfully");
    // final userDoc = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userId)
    //     .get();

        
  } catch (e) {
    DPrint.error("Failed to send shipment notification: $e");
    // Don't rethrow if you don't want to break label generation
  }
}


// fbRIsE-yQ8OKFAhMDNdvpD:APA91bEFQpYsDbkOmbYQFv0IANEv1ZkMHOG5X72tzwtNmkjXprwl6g7Ccl1HtyrS1AN461NHo2Qt8b28SjZZ4QMHfrnFgUy0u2F00BvjHAK5V1uNiNVwdLE