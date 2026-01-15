import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_willbefore/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutx_core/flutx_core.dart';

import '../../../../core/services/shippo_service.dart';
import '../../../setting/presentation/provider/warehouse_provider.dart';
import '../../domain/entities/order_entities.dart';
import '../providers/order_provider.dart';
import '../providers/send_shipment_notification.dart';

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
  String? _trackingUrl;
  String? _error;

  final _shippo = AdminShippoService();

  // Parcel Inputs
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String _distanceUnit = 'in';
  String _massUnit = 'oz';

  @override
  void initState() {
    super.initState();
    _lengthController = TextEditingController(text: '10');
    _widthController = TextEditingController(text: '6');
    _heightController = TextEditingController(text: '4');

    // Calculate initial weight from order items
    final totalWeightOz = widget.order.items.fold<double>(
      0,
      (sum, item) => sum + (item.product.weightOz) * item.quantity,
    );
    // If calculated weight is 0, default to 8 oz
    final initialWeight = totalWeightOz > 0 ? totalWeightOz : 8.0;
    _weightController = TextEditingController(text: initialWeight.toString());
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  //  Address validation helper
  // --------------------------------------------------------------
  bool _isValidAddress(Map<String, dynamic>? addr, {required bool isUS}) {
    if (addr == null) return false;

    // Check modern validation results first
    if (addr.containsKey('validation_results')) {
      final validation = addr['validation_results'];
      if (validation is Map && validation['is_valid'] == true) {
        return true;
      }
    }

    if (isUS) return addr['object_state'] == 'VALID';
    return addr['object_id'] != null;
  }

  // --------------------------------------------------------------
  //  Generate label
  // --------------------------------------------------------------
  Future<void> _generateLabel() async {
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
        String msg;
        try {
          // Attempt to extract friendly messages
          final messages = fromAddr['messages'] as List?;
          if (messages != null && messages.isNotEmpty) {
            msg = messages
                .map(
                  (m) => m is Map ? (m['text'] ?? m.toString()) : m.toString(),
                )
                .join(', ');
          } else {
            // If no messages but invalid, dump full JSON
            msg = 'Full Response: ${jsonEncode(fromAddr)}';
          }
        } catch (_) {
          msg = 'Response: $fromAddr';
        }
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
        String msg;
        try {
          final messages = toAddr['messages'] as List?;
          if (messages != null && messages.isNotEmpty) {
            msg = messages
                .map(
                  (m) => m is Map ? (m['text'] ?? m.toString()) : m.toString(),
                )
                .join(', ');
          } else {
            msg = 'Full Response: ${jsonEncode(toAddr)}';
          }
        } catch (_) {
          msg = 'Response: $toAddr';
        }
        throw Exception('Customer address invalid: $msg');
      }

      // ---- 4. Parcel -------------------------------------------------------------
      // ---- 4. Parcel -------------------------------------------------------------
      // Get values from controllers
      final length = double.tryParse(_lengthController.text);
      final width = double.tryParse(_widthController.text);
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);

      if (length == null || width == null || height == null || weight == null) {
        throw Exception(
          'Please enter valid numeric values for dimensions and weight.',
        );
      }

      final parcelId = await _shippo.createParcel(
        length: length,
        width: width,
        height: height,
        distanceUnit: _distanceUnit,
        weight: weight,
        massUnit: _massUnit,
      );
      // Removed null check as createParcel throws on error

      // ---- 4.5 Customs Declaration (International) -------------------------------
      String? customsDeclarationId;
      final bool isDomesticUS = isWarehouseUS && isCustomerUS;

      if (!isDomesticUS) {
        final List<String> customsItemIds = [];
        for (final item in widget.order.items) {
          final itemId = await _shippo.createCustomsItem(
            description: item.product.title, // using title from Product entity
            quantity: item.quantity.toDouble(),
            netWeight: item.product.weightOz > 0 ? item.product.weightOz : 1.0,
            massUnit: 'oz',
            valueAmount: item.product.effectivePrice,
            valueCurrency: 'USD',
            originCountry: warehouse.country ?? 'US',
          );
          customsItemIds.add(itemId);
        }

        customsDeclarationId = await _shippo.createCustomsDeclaration(
          customsItemIds: customsItemIds,
          certify: true,
          signer: warehouse.name ?? 'Sender',
        );
      }

      // ---- 5. Shipment -----------------------------------------------------------
      final shipment = await _shippo.createShipment(
        addressFromId: fromAddr['object_id'] as String,
        addressToId: toAddr['object_id'] as String,
        parcelIds: [parcelId],
        customsDeclarationId: customsDeclarationId,
      );
      // Removed null check as createShipment throws on error

      // ---- 6. Rate selection -----------------------------------------------------
      final rates = shipment['rates'] as List;
      if (rates.isEmpty) {
        throw Exception('No shipping rates returned by Shippo');
      }

      // reused isDomesticUS from above

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

      // Check for Shippo/Carrier API errors (e.g. invalid address/phone)
      if (transaction['status'] != 'SUCCESS') {
        String msg = 'Label purchase failed';
        if (transaction['messages'] != null) {
          final messages = transaction['messages'] as List;
          msg = messages.map((m) => m['text'] ?? m.toString()).join('\n');
        }
        throw Exception(msg);
      }

      // Ensure tracking number exists
      final trackingRaw = transaction['tracking_number']?.toString();
      if (trackingRaw == null || trackingRaw.isEmpty) {
        throw Exception(
          'Carrier did not provide a tracking number. Label generation aborted.',
        );
      }

      // ---- 8. Update order -------------------------------------------------------
      final success = await ref
          .read(adminOrderProvider.notifier)
          .fulfillOrder(
            orderId: widget.order.id,
            trackingNumber: transaction['tracking_number'],
            trackingUrl: transaction['tracking_url_provider'],
            labelUrl: transaction['label_url'],
            shippoTransactionId: transaction['object_id'],
          );
      if (!success) throw Exception('Failed to update order in database');

      // ---- 9. UI success ---------------------------------------------------------
      setState(() {
        final tracking = transaction['tracking_number']?.toString();
        _trackingNumber = (tracking != null && tracking.isNotEmpty)
            ? tracking
            : 'Not Provided by Carrier';
        _labelUrl = transaction['label_url'];
        _trackingUrl = transaction['tracking_url_provider'];
      });

      // ---- 10. Send Notification --------------------------------------------------
      await sendShipmentNotification(
        orderId: widget.order.id,
        userId: widget.order.userId,
        trackingNumber: transaction['tracking_number'],
        trackingUrl: transaction['tracking_url_provider'],
        labelUrl: transaction['label_url'],
      );

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
            // Parcel Details Input
            if (_labelUrl == null) ...[
              _buildParcelDetailsCard(),
              const SizedBox(height: 24),
            ],

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

            if (_labelUrl != null) ...[
              _buildSuccessCard(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(_labelUrl!)),
                    icon: const Icon(Icons.print),
                    label: const Text('Print Label'),
                  ),
                  if (_trackingUrl != null && _trackingUrl!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(_trackingUrl!)),
                      icon: const Icon(Icons.location_on),
                      label: const Text('Track Package'),
                    ),
                  ],
                ],
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

  Widget _buildParcelDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Parcel Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _lengthController,
                  label: 'Length',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _widthController,
                  label: 'Width',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _heightController,
                  label: 'Height',
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 75,
                child: DropdownButtonFormField<String>(
                  value: _distanceUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),
                  items: ['in', 'cm', 'ft', 'mm']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _distanceUnit = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildTextField(
                  controller: _weightController,
                  label: 'Weight',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _massUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),
                  items: ['oz', 'lb', 'kg', 'g']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _massUnit = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid';
        return null;
      },
    );
  }
}
