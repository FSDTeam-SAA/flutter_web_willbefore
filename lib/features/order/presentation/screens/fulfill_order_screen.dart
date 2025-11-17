// lib/feature/admin/presentation/screens/fulfill_order_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_willbefore/core/constants/app_colors.dart';
import 'package:flutter_web_willbefore/features/order/presentation/providers/send_shipment_notification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutx_core/flutx_core.dart';

import '../../../../core/services/shippo_service.dart';
import '../../../setting/domain/models/warehouse_address.dart';
import '../../../setting/presentation/provider/warehouse_provider.dart';
import '../../domain/entities/order_entities.dart';
import '../providers/order_provider.dart';

class FullfillOrderScreen extends ConsumerStatefulWidget {
  final Order order;
  const FullfillOrderScreen({super.key, required this.order});

  @override
  ConsumerState<FullfillOrderScreen> createState() =>
      _FulfillOrderScreenState();
}

class _FulfillOrderScreenState extends ConsumerState<FullfillOrderScreen> {
  bool _isLoading = false;
  String? _trackingNumber;
  String? _labelUrl;
  String? _error;

  final _shippo = AdminShippoService();

  // --------------------------------------------------------------
  //  Address validation helper
  // --------------------------------------------------------------
  bool _isValidAddress(Map<String, dynamic>? addr, {required bool isUS}) {
    if (addr == null) return false;
    if (isUS) return addr['object_state'] == 'VALID';
    return addr['object_id'] != null;
  }

  // --------------------------------------------------------------
  //  Generate label
  // --------------------------------------------------------------
  Future<void> _generateLabel() async {
    sendShipmentNotification(
      fcmToken:
          "d-LkHO-TSS2V6fE-qlY-MC:APA91bGuWAWYNPo9Jd4EuSxNLkRLtIryTZVWoZbUA7gS19Lbdglo_P_8HLL14idjAPdK3qvrmBv55wc7fTdfq6MLoF3pi4GgEWGoI18j7bsOalAN8uhVpkU",
      orderId: "233",
    );

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ---- 1. Warehouse address -------------------------------------------------
      final warehouseState = ref.read(warehouseProvider);
      if (warehouseState.address == null) {
        // If not loaded yet, trigger load and wait
        final provider = ref.read(warehouseProvider.notifier);
        provider.refresh();
        if (ref.read(warehouseProvider).address == null) {
          throw Exception(
            'Warehouse address not configured. Please set it in Admin → Settings.',
          );
        }
      }
      final warehouse = ref.read(warehouseProvider).address!;
      final bool isWarehouseUS = warehouse.country?.toUpperCase() == 'US';

      // ---- 2. FROM address -------------------------------------------------------
      final fromAddr = await _shippo.createAddress(
        name: warehouse.name ?? 'Warehouse',
        street1: warehouse.street1 ?? '',
        city: warehouse.city ?? '',
        state: warehouse.state ?? '',
        zip: warehouse.zip ?? '',
        country: warehouse.country ?? '',
        isResidential: warehouse.isResidential,
      );

      DPrint.log('FROM Address: $fromAddr');
      if (!_isValidAddress(fromAddr, isUS: isWarehouseUS)) {
        final msg = fromAddr?['messages']?.join(', ') ?? 'Unknown error';
        throw Exception('Warehouse address invalid: $msg');
      }

      // ---- 3. TO address ---------------------------------------------------------
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

      final bool isCustomerUS =
          widget.order.shippingAddress.country.toUpperCase() == 'US';
      if (!_isValidAddress(toAddr, isUS: isCustomerUS)) {
        final msg = toAddr?['messages']?.join(', ') ?? 'Unknown error';
        throw Exception('Customer address invalid: $msg');
      }

      // ---- 4. Parcel -------------------------------------------------------------
      final totalWeightOz = widget.order.items.fold<double>(
        0,
        (sum, item) => sum + (item.product.weightOz ?? 0) * item.quantity,
      );

      final parcelId = await _shippo.createParcel(
        length: 10,
        width: 6,
        height: 4,
        distanceUnit: 'in',
        weight: totalWeightOz > 0 ? totalWeightOz : 8,
        massUnit: 'oz',
      );
      if (parcelId == null) throw Exception('Failed to create parcel');

      // ---- 5. Shipment -----------------------------------------------------------
      final shipment = await _shippo.createShipment(
        addressFromId: fromAddr!['object_id'] as String,
        addressToId: toAddr!['object_id'] as String,
        parcelIds: [parcelId],
      );
      if (shipment == null) throw Exception('Failed to create shipment');

      // ---- 6. Rate selection -----------------------------------------------------
      final rates = shipment['rates'] as List;
      if (rates.isEmpty) {
        throw Exception('No shipping rates returned by Shippo');
      }

      final bool isDomesticUS = isWarehouseUS && isCustomerUS;

      Map<String, dynamic> selectedRate;

      if (isDomesticUS) {
        final uspsRates = rates
            .where(
              (r) => (r['provider'] as String).toUpperCase().contains('USPS'),
            )
            .toList();

        if (uspsRates.isEmpty) {
          throw Exception('No USPS rates for domestic shipment');
        }

        selectedRate = uspsRates.reduce(
          (a, b) =>
              double.parse(a['amount']) < double.parse(b['amount']) ? a : b,
        );
      } else {
        // International / non-US → cheapest overall
        selectedRate = rates.reduce(
          (a, b) =>
              double.parse(a['amount']) < double.parse(b['amount']) ? a : b,
        );
      }

      DPrint.log(
        'Selected Rate: ${selectedRate['provider']} – \$${selectedRate['amount']}',
      );

      // ---- 7. Buy label ---------------------------------------------------------
      final transaction = await _shippo.buyLabel(selectedRate['object_id']);
      if (transaction == null) throw Exception('Failed to purchase label');

      // ---- 8. Update order -------------------------------------------------------
      final success = await ref
          .read(adminOrderProvider.notifier)
          .fulfillOrder(
            orderId: widget.order.id,
            trackingNumber: transaction['tracking_number'],
            labelUrl: transaction['label_url'],
            shippoTransactionId: transaction['object_id'],
          );
      if (!success) throw Exception('Failed to update order in database');

      // ---- 9. UI success ---------------------------------------------------------
      setState(() {
        _trackingNumber = transaction['tracking_number'];
        _labelUrl = transaction['label_url'];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Label generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
      DPrint.error('Fulfill Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --------------------------------------------------------------
  //  UI
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final warehouseState = ref.watch(warehouseProvider);

    // Loading warehouse address
    if (warehouseState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Warehouse not set
    if (warehouseState.address == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fulfill Order')),
        body: const Center(
          child: Text(
            'Warehouse address not configured.\nPlease set it in Admin → Settings.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

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
            _buildSummaryCard(),
            const SizedBox(height: 24),

            // Generate button
            if (_labelUrl == null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateLabel,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.local_shipping,
                          color: AppColors.white,
                        ),
                  label: Text(
                    _isLoading
                        ? 'Generating Label...'
                        : 'Generate Shipping Label',
                    style: const TextStyle(color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLaurel,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

            // Success UI
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

            // Error UI
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  //  UI Helpers
  // --------------------------------------------------------------
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping To',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(widget.order.shippingAddress.fullName),
          Text(widget.order.shippingAddress.addressLine1),
          Text(
            '${widget.order.shippingAddress.city}, ${widget.order.shippingAddress.state} ${widget.order.shippingAddress.postalCode}',
          ),
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
          const Text(
            'Label Generated!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tracking: $_trackingNumber',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
