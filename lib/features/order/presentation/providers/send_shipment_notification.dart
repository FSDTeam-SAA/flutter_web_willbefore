import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutx_core/core/debug_print.dart';

Future<void> sendShipmentNotification({
  required String orderId,
  required String userId,
  required String? trackingNumber,
  required String? trackingUrl,
  required String? labelUrl,
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

  final fcmToken = userDoc.data()?['fcmToken'] as String?;

  if (fcmToken == null || fcmToken.isEmpty) {
    DPrint.warn("No FCM token found for user: $userId");
    // We still want to persist the notification even if push fails
  } else {
    // 2. Send Push Notification via Cloud Function
    final callable = FirebaseFunctions.instance.httpsCallable(
      "startShipment",
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );

    try {
      await callable.call({
        "fcmToken": fcmToken,
        "orderId": orderId,
        "trackingNumber": trackingNumber,
        "trackingUrl": trackingUrl,
        "labelUrl": labelUrl,
      });
      DPrint.log("Push notification sent successfully");
    } catch (e) {
      DPrint.error("Failed to send shipment notification: $e");
    }
  }

  // 3. Add to Notification Collection
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
          'title': 'Order Shipped',
          'body':
              'Your order #$orderId has been shipped! Tracking: ${trackingNumber ?? "N/A"}',
          'orderId': orderId,
          'trackingNumber': trackingNumber,
          'trackingUrl': trackingUrl,
          'labelUrl': labelUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'shipment',
        });
    DPrint.log("Notification added to collection successfully");
  } catch (e) {
    DPrint.error("Failed to add notification to collection: $e");
  }
}


// fbRIsE-yQ8OKFAhMDNdvpD:APA91bEFQpYsDbkOmbYQFv0IANEv1ZkMHOG5X72tzwtNmkjXprwl6g7Ccl1HtyrS1AN461NHo2Qt8b28SjZZ4QMHfrnFgUy0u2F00BvjHAK5V1uNiNVwdLE