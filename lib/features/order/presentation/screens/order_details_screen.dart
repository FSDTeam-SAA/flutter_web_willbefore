import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_willbefore/core/constants/app_colors.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/route_endpoint.dart';
import '../../domain/entities/order_entities.dart';
import '../../domain/entities/user_entities.dart';
import '../providers/order_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminOrderState = ref.watch(adminOrderProvider);
    final currentOrder = adminOrderState.orders.firstWhere(
      (o) => o.id == order.id,
      orElse: () => order,
    );

    final user = adminOrderState.users.firstWhere(
      (user) => user.id == currentOrder.userId,
      orElse: () => User(
        id: currentOrder.userId,
        name: currentOrder.shippingAddress.fullName,
        email: currentOrder.shippingAddress.email,
        phoneNumber: currentOrder.shippingAddress.phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(currentOrder),
            if (currentOrder.trackingNumber != null ||
                currentOrder.labelUrl != null) ...[
              const SizedBox(height: 24),
              _buildShipmentInfo(currentOrder),
            ],
            const SizedBox(height: 24),
            _buildCustomerInfo(user, currentOrder),
            const SizedBox(height: 24),
            _buildOrderItems(currentOrder),
            const SizedBox(height: 24),
            _buildShippingInfo(currentOrder),
            const SizedBox(height: 24),
            // _buildStatusUpdateSection(context, ref, currentOrder),
            _buildFulfillButton(context, currentOrder),
            const SizedBox(height: 24),
            _buildActionButtons(context, ref, user, currentOrder),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    User user,
    Order currentOrder,
  ) {
    final bool canFulfill = currentOrder.status == OrderStatus.confirmed;
    final bool canRefund = [
      OrderStatus.pending,
      OrderStatus.cancelled,
    ].contains(currentOrder.status);

    DPrint.log('Order Status: ${canRefund}');

    if (!canFulfill && !canRefund) return const SizedBox.shrink();

    return Column(
      children: [
        // === Fulfill Order Button ===
        if (canFulfill)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.goNamed(
                    RouteEndpoint.fullfillOrder,
                    extra: currentOrder,
                  );
                },
                icon: const Icon(Icons.local_shipping, color: Colors.white),
                label: const Text('Fulfill Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLaurel,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

        // === Cancel Order Button ===
        if (canRefund)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCancelConfirmationDialog(
                context,
                ref,
                user,
                currentOrder,
              ),
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: Text(
                currentOrder.status == OrderStatus.confirmed
                    ? 'Cancel Order & Issue Refund (Post-Delivery)'
                    : 'Cancel Order',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    User user,
    Order currentOrder,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Cancellation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'This will CANCEL the order and issue a FULL refund of \$${order.total.toStringAsFixed(2)} to the customer.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Order #${order.id.substring(0, 8)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              _processRefund(context, ref, user);
            },
            child: const Text(
              'Yes, Cancel & Refund',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processRefund(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing cancellation and refund...'),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('refundOrder')
          .call({
            'paymentIntentId': order.paymentIntentId,
            // 'paymentIntentId': "pi_3SU1y32IE5e3lR4S1qATTF7D",
            /// 'amount': (order.total * 100).toInt(),  Uncomment for [partial refund]
            'reason': 'requested_by_customer',
          });

      if (result.data['success'] == true) {
        // Optional: Update order status to cancelled
        await ref
            .read(adminOrderProvider.notifier)
            .updateOrderStatus(order.id, OrderStatus.cancelled);

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(order.userId)
            .get();

        final fcmToken = userDoc.data()?['fcmToken'] as String?;

        if (fcmToken != null && fcmToken.isNotEmpty) {
          try {
            await FirebaseFunctions.instance
                .httpsCallable('sendRefundNotification')
                .call({
                  'fcmToken': fcmToken,
                  'orderId': order.id,
                  'customerName': user.name ?? order.shippingAddress.fullName,
                  'totalAmount': order.total.toStringAsFixed(2),
                });
            DPrint.log("Refund notification sent successfully");
          } catch (e) {
            DPrint.error("Failed to send refund notification: $e");
            // Don't fail the whole refund if notification fails
          }
        } else {
          DPrint.log(
            "No FCM token found for user ${order.userId}, skipping notification",
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Order cancelled! Customer has been refunded.',
              ),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  // Optional: Navigate to refund details
                },
              ),
            ),
          );
        }
      }
    } on FirebaseFunctionsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refund failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOrderSummary(Order currentOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Date:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(currentOrder.createdAt),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                '\$${currentOrder.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: currentOrder.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentOrder.status.displayName,
                  style: TextStyle(
                    color: currentOrder.status.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentInfo(Order currentOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipment Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (currentOrder.trackingNumber != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tracking Number:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  currentOrder.trackingNumber!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (currentOrder.labelUrl != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        launchUrl(Uri.parse(currentOrder.labelUrl!)),
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('View Label'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (currentOrder.labelUrl != null &&
                  currentOrder.trackingUrl != null)
                const SizedBox(width: 12),
              if (currentOrder.trackingUrl != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        launchUrl(Uri.parse(currentOrder.trackingUrl!)),
                    icon: const Icon(Icons.location_on, size: 18),
                    label: const Text('Track Package'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(User user, Order currentOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            user.name ?? 'Unknown User',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (user.phoneNumber != null) ...[
            const SizedBox(height: 8),
            Text(
              user.phoneNumber!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order currentOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...currentOrder.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: item.product.imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrls.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.orange[100],
                                    child: const Icon(
                                      Icons.shopping_bag,
                                      color: Colors.orange,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              color: Colors.orange[100],
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.orange,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${(item.product.actualPrice * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index < order.items.length - 1) const Divider(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(Order currentOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            currentOrder.shippingAddress.fullName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            currentOrder.shippingAddress.addressLine1,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '${currentOrder.shippingAddress.city}, ${currentOrder.shippingAddress.state} ${currentOrder.shippingAddress.postalCode}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (currentOrder.shippingAddress.country.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              currentOrder.shippingAddress.country,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFulfillButton(BuildContext context, Order currentOrder) {
    if (currentOrder.status != OrderStatus.pending)
      return const SizedBox.shrink();

    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          context.goNamed(RouteEndpoint.fullfillOrder, extra: currentOrder);
        },
        icon: const Icon(
          Icons.local_shipping,
          size: 18,
          color: AppColors.white,
        ),
        label: const Text(
          'Fulfill Order',
          style: TextStyle(fontSize: 16, color: AppColors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLaurel,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusUpdateSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Order Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...OrderStatus.values.map(
            (status) => RadioListTile<OrderStatus>(
              title: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: status.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(status.displayName),
                ],
              ),
              value: status,
              groupValue: order.status,
              onChanged: (value) {
                if (value != null) {
                  _updateOrderStatus(context, ref, order.id, value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    OrderStatus newStatus,
  ) async {
    final success = await ref
        .read(adminOrderProvider.notifier)
        .updateOrderStatus(orderId, newStatus);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Order status updated successfully'
                : 'Failed to update order status',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
