import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';

import '../provider/shipping_provider.dart';

class ShippingSettingsWidget extends ConsumerStatefulWidget {
  const ShippingSettingsWidget({super.key});

  @override
  ConsumerState<ShippingSettingsWidget> createState() =>
      _ShippingSettingsWidgetState();
}

class _ShippingSettingsWidgetState
    extends ConsumerState<ShippingSettingsWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _rateCtrl;

  @override
  void initState() {
    super.initState();
    _rateCtrl = TextEditingController();
    final rate = ref.read(shippingProvider).flatRate;
    if (rate != null) _rateCtrl.text = rate.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final rate = double.parse(_rateCtrl.text.trim());
    final success = await ref.read(shippingProvider.notifier).save(rate);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipping rate saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shippingProvider);

    ref.listen<ShippingState>(shippingProvider, (prev, next) {
      if (next.flatRate != null && prev?.flatRate == null) {
        _rateCtrl.text = next.flatRate!.toStringAsFixed(2);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Gap.h8,
            const Text(
              'Set a flat shipping rate charged to all customers at checkout.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Gap.h16,
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              TextFormField(
                controller: _rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Flat Shipping Rate (USD) *',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                  if (double.parse(v.trim()) < 0) return 'Must be 0 or more';
                  return null;
                },
              ),
              Gap.h16,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _save,
                  child: const Text('Save Shipping Rate'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
