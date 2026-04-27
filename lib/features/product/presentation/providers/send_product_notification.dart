import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutx_core/core/debug_print.dart';
import '../../domain/entrity/product.dart';
import 'package:flutter/material.dart';

Future<bool> sendProductNotification(
  BuildContext context,
  Product product,
) async {
  final callable = FirebaseFunctions.instance.httpsCallable(
    "sendProductNotification",
    options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
  );

  try {
    final result = await callable.call({
      "id": product.id,
      "name": product.title,
      "shortDescription": product.description,
      "imageUrl": product.imageUrls.isNotEmpty ? product.imageUrls.first : "",
    });

    DPrint.log(
      "Push notification request sent to Cloud Function: ${result.data}",
    );

    if (result.data['success'] == true) {
      /*
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification sent successfully for ${product.title}!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      */
      return true;
    } else {
      throw Exception(result.data['error'] ?? "Unknown error");
    }
  } catch (e) {
    DPrint.error("Failed to send product notification: $e");
    /*
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    */
    return false;
  }
}
