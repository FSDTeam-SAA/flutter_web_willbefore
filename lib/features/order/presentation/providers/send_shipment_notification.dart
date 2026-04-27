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
  // 1. Send Push Notification via Cloud Function (Multicast)
  final callable = FirebaseFunctions.instance.httpsCallable(
    "startShipment",
    options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
  );

  final String title = 'Order Shipped';
  final String msg =
      'Your order #$orderId has been shipped! Tracking: ${trackingNumber ?? "N/A"}';

  try {
    await callable.call({
      "userId": userId, // New: Function handles fetching all tokens
      "orderId": orderId,
      "trackingNumber": trackingNumber,
      "trackingUrl": trackingUrl,
      "labelUrl": labelUrl,
      "title": title,
      "msg": msg,
    });
    DPrint.log("Push notification request sent to Cloud Function");
  } catch (e) {
    DPrint.error("Failed to send shipment notification: $e");
  }

  // 3. Add to Notification Collection
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
          'title': 'Order Shipped',
          'message':
              'Your order #$orderId has been shipped! Tracking: ${trackingNumber ?? "N/A"}',
          'orderId': orderId,
          'tracking_number': trackingNumber, 
          'metadata': {
            'tracking_url': trackingUrl,
            'label_url': labelUrl,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
          'type': 'order_shipped',
        });
    DPrint.log("Notification added to collection successfully");
  } catch (e) {
    DPrint.error("Failed to add notification to collection: $e");
  }
}


// fbRIsE-yQ8OKFAhMDNdvpD:APA91bEFQpYsDbkOmbYQFv0IANEv1ZkMHOG5X72tzwtNmkjXprwl6g7Ccl1HtyrS1AN461NHo2Qt8b28SjZZ4QMHfrnFgUy0u2F00BvjHAK5V1uNiNVwdLE