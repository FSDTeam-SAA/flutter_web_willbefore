import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutx_core/core/debug_print.dart';

import '../../domain/models/promo_model.dart';

Future<bool> sendPromoNotification(
  BuildContext context,
  PromoModel promo,
) async {
  // Sending to every user takes a while. A short timeout here would report
  // failure while the function keeps running, inviting a duplicate send.
  final callable = FirebaseFunctions.instance.httpsCallable(
    "sendPromoNotification",
    options: HttpsCallableOptions(timeout: const Duration(minutes: 5)),
  );

  try {
    final result = await callable.call({"promoId": promo.id});
    DPrint.log("Promo notification result: ${result.data}");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sent to ${result.data['successCount']} devices and '
            '${result.data['userCount']} in-app inboxes.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
    return true;
  } catch (e) {
    DPrint.error("Failed to send promo notification: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }
}

/// Shows what will be sent and confirms before notifying all users, so admins
/// don't accidentally mass-notify with a stray click.
Future<void> confirmAndSendPromoNotification(
  BuildContext context,
  PromoModel promo,
) async {
  final imageUrl = promo.imageUrl;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Notify all users?'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              '${promo.title}: ${promo.discountLabel}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('Use code ${promo.code} at checkout.'),
            const SizedBox(height: 16),
            const Text(
              'This goes to every user straight away and cannot be undone.',
            ),
            if (imageUrl == null) ...[
              const SizedBox(height: 8),
              const Text(
                'This promo has no image, so it will send as a small '
                'notification. Edit the promo to add one.',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Send Notification'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    await sendPromoNotification(context, promo);
  }
}
