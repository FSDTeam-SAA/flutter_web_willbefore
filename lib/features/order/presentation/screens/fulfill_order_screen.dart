// lib/feature/admin/presentation/screens/fulfill_order_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutx_core/flutx_core.dart';

import '../../../../core/services/shippo_service.dart';
import '../../domain/entities/order_entities.dart';

import '../providers/order_provider.dart';

class FulfillOrderScreen extends ConsumerStatefulWidget {
  final Order order;
  const FulfillOrderScreen({super.key, required this.order});

  @override
  ConsumerState<FulfillOrderScreen> createState() => _FulfillOrderScreenState();
}

class _FulfillOrderScreenState extends ConsumerState<FulfillOrderScreen> {
  bool _isLoading = false;
  String? _trackingNumber;
  String? _labelUrl;
  String? _error;

  final _shippo = AdminShippoService();

  Future<void> _generateLabel() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Warehouse Address
      final fromAddr = await _shippo.createAddress(
        name: 'SmileTreats Warehouse',
        street1: '123 Candy Lane',
        city: 'San Francisco',
        state: 'CA',
        zip: '94103',
        country: 'US',
        isResidential: false,
      );
      if (fromAddr == null) throw Exception('Failed to create warehouse address');

      // 2. Customer Address
      final toAddr = await _shippo.createAddress(
        name: widget.order.shippingAddress.fullName,
        street1: widget.order.shippingAddress.addressLine1,
        city: widget.order.shippingAddress.city,
        state: widget.order.shippingAddress.state,
        zip: widget.order.shippingAddress.postalCode,
        country: widget.order.shippingAddress.country,
        phone: widget.order.shippingAddress.phoneNumber,
        email: widget.order.shippingAddress.email,
      );
      if (toAddr == null) throw Exception('Failed to create customer address');

      // 3. Parcel (sum weight & use avg dimensions)
      final totalWeightOz = widget.order.items.fold<double>(
        0,
        (sum, item) => sum + (item.product.weightOz ?? 0) * item.quantity,
      );

      final parcelId = await _shippo.createParcel(
        length: 10,
        width: 6,
        height: 4,
        distanceUnit: 'in',
        weight: totalWeightOz > 0 ? totalWeightOz : 8, // fallback
        massUnit: 'oz',
      );
      if (parcelId == null) throw Exception('Failed to create parcel');

      // 4. Shipment
      final shipment = await _shippo.createShipment(
        addressFromId: fromAddr['object_id'],
        addressToId: toAddr['object_id'],
        parcelIds: [parcelId],
      );
      if (shipment == null) throw Exception('Failed to create shipment');

      // 5. Pick cheapest USPS rate
      final rates = shipment['rates'] as List;
      final uspsRate = rates
          .where((r) => (r['provider'] as String).contains('USPS'))
          .reduce((a, b) => double.parse(a['amount']) < double.parse(b['amount']) ? a : b);

      // 6. Buy Label
      final transaction = await _shippo.buyLabel(uspsRate['object_id']);
      if (transaction == null) throw Exception('Failed to purchase label');

      // 7. Update Order
      final success = await ref.read(adminOrderProvider.notifier).fulfillOrder(
        orderId: widget.order.id,
        trackingNumber: transaction['tracking_number'],
        labelUrl: transaction['label_url'],
        shippoTransactionId: transaction['object_id'],
      );

      if (!success) throw Exception('Failed to update order in database');

      setState(() {
        _trackingNumber = transaction['tracking_number'];
        _labelUrl = transaction['label_url'];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Label generated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
      DPrint.error('Fulfill Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fulfill Order #${widget.order.id.substring(0, 8)}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 24),
            // Action Button
            if (_labelUrl == null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateLabel,
                  icon: _isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.local_shipping),
                  label: Text(_isLoading ? 'Generating Label...' : 'Generate Shipping Label'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            // Success State
            if (_labelUrl != null) ...[
              _buildSuccessCard(),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(_labelUrl!)),
                  icon: const Icon(Icons.print),
                  label: const Text('Print Label'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
            ],
            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shipping To', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.order.shippingAddress.fullName),
          Text(widget.order.shippingAddress.addressLine1),
          Text('${widget.order.shippingAddress.city}, ${widget.order.shippingAddress.state} ${widget.order.shippingAddress.postalCode}'),
          Text(widget.order.shippingAddress.country),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 12),
          const Text('Label Generated!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tracking: $_trackingNumber', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}