import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutx_core/core/debug_print.dart';

Future<void> sendShipmentNotification({
  required String fcmToken,
  required String orderId,
}) async {
  final callable = FirebaseFunctions.instance.httpsCallable(
    "startShipment",
    options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
  );

  try {
    await callable.call({"fcmToken": fcmToken, "orderId": orderId});
    DPrint.log("Push notification sent successfully");
  } catch (e) {
    DPrint.error("Failed to send shipment notification: $e");
    // Don't rethrow if you don't want to break label generation
  }
}


// fbRIsE-yQ8OKFAhMDNdvpD:APA91bEFQpYsDbkOmbYQFv0IANEv1ZkMHOG5X72tzwtNmkjXprwl6g7Ccl1HtyrS1AN461NHo2Qt8b28SjZZ4QMHfrnFgUy0u2F00BvjHAK5V1uNiNVwdLE