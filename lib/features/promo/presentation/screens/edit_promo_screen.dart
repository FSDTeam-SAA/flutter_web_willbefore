import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../domain/models/promo_model.dart';
import '../../domain/requests/update_promo_request.dart';
import '../providers/promos_provider.dart';

class EditPromoScreen extends ConsumerStatefulWidget {
  final String promoId;
  const EditPromoScreen({super.key, required this.promoId});

  @override
  ConsumerState<EditPromoScreen> createState() => _EditPromoScreenState();
}

class _EditPromoScreenState extends ConsumerState<EditPromoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountPercentageController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _existingImageUrl;
  bool _isActive = true;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _discountPercentageController.dispose();
    _discountAmountController.dispose();
    _minimumOrderController.dispose();
    _usageLimitController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _initFromPromo(PromoModel promo) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = promo.title;
    _codeController.text = promo.code;
    _descriptionController.text = promo.description;
    _discountPercentageController.text =
        promo.discountPercentage > 0 ? promo.discountPercentage.toString() : '0';
    _discountAmountController.text =
        promo.discountAmount != null ? promo.discountAmount.toString() : '';
    _minimumOrderController.text =
        promo.minimumOrderAmount != null ? promo.minimumOrderAmount.toString() : '';
    _usageLimitController.text = promo.usageLimit.toString();
    _startDate = promo.startDate;
    _endDate = promo.endDate;
    _startDateController.text = DateFormat('dd/MM/yyyy').format(promo.startDate);
    _endDateController.text = DateFormat('dd/MM/yyyy').format(promo.endDate);
    _existingImageUrl = promo.imageUrl;
    _isActive = promo.isActive;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedImageBytes = file.bytes;
          _selectedImageName = file.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdatePromoRequest(
      id: widget.promoId,
      title: _titleController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      description: _descriptionController.text.trim(),
      discountPercentage: double.tryParse(_discountPercentageController.text) ?? 0,
      discountAmount: _discountAmountController.text.isNotEmpty
          ? double.tryParse(_discountAmountController.text)
          : null,
      minimumOrderAmount: _minimumOrderController.text.isNotEmpty
          ? double.tryParse(_minimumOrderController.text)
          : null,
      startDate: _startDate!,
      endDate: _endDate!,
      imageBytes: _selectedImageBytes,
      imageName: _selectedImageName,
      existingImageUrl: _selectedImageBytes != null ? null : _existingImageUrl,
      isActive: _isActive,
      usageLimit: int.tryParse(_usageLimitController.text) ?? 0,
    );

    final success = await ref.read(promosProvider.notifier).updatePromo(request);

    if (success && mounted) {
      context.go(RouteEndpoint.promos);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promo updated successfully!'),
          backgroundColor: AppColors.primaryLaurel,
        ),
      );
    } else if (mounted) {
      final errorMessage = ref.read(promosProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final promosState = ref.watch(promosProvider);

    // Find promo from already-loaded list
    final promo = promosState.promos
        .cast<PromoModel?>()
        .firstWhere((p) => p?.id == widget.promoId, orElse: () => null);

    if (promosState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryLaurel));
    }

    if (promo == null) {
      return const Center(child: Text('Promo not found.'));
    }

    _initFromPromo(promo);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Promo Title', _titleController, 'Enter promo title...', validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter a promo title';
                    return null;
                  }),
                  const SizedBox(height: 24),
                  _buildCodeSection(),
                  const SizedBox(height: 24),
                  _buildSection('Description', _descriptionController, 'Enter promo description...', maxLines: 3, validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter a description';
                    return null;
                  }),
                  const SizedBox(height: 24),
                  _buildDiscountSection(),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                  const SizedBox(height: 24),
                  _buildSettingsSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(promosState.isUpdating),
                ],
              ),
            ),

            const SizedBox(width: 32),

            // Right Column — Image
            Expanded(child: _buildImageSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textAppBlack)),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Promo Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textAppBlack)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(hintText: 'Enter promo code...'),
          onChanged: (value) {
            _codeController.value = _codeController.value.copyWith(
              text: value.toUpperCase(),
              selection: TextSelection.collapsed(offset: value.length),
            );
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Please enter a promo code';
            if (value.length < 3) return 'Promo code must be at least 3 characters';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Discount Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textAppBlack)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _discountPercentageController,
                decoration: const InputDecoration(labelText: 'Discount Percentage (%)', hintText: '0'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final pct = double.tryParse(value);
                  if (pct == null || pct < 0 || pct > 100) return 'Enter valid percentage (0-100)';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _discountAmountController,
                decoration: const InputDecoration(labelText: 'Fixed Discount Amount', hintText: '0.00'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _minimumOrderController,
          decoration: const InputDecoration(labelText: 'Minimum Order Amount', hintText: '0.00'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textAppBlack)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select start date',
                  suffixIcon: IconButton(onPressed: () => _selectDate(context, true), icon: const Icon(Icons.calendar_today)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Please select start date' : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('End Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textAppBlack)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select end date',
                  suffixIcon: IconButton(onPressed: () => _selectDate(context, false), icon: const Icon(Icons.calendar_today)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please select end date';
                  if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
                    return 'End date must be after start date';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textAppBlack)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _usageLimitController,
          decoration: const InputDecoration(labelText: 'Usage Limit (0 for unlimited)', hintText: '0'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value ?? true),
              activeColor: AppColors.primaryLaurel,
            ),
            const Text('Active', style: TextStyle(color: AppColors.textAppBlack, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Promo Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textAppBlack)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildImagePreview(),
          ),
        ),
        if (_existingImageUrl != null || _selectedImageBytes != null)
          TextButton.icon(
            onPressed: () => setState(() {
              _selectedImageBytes = null;
              _selectedImageName = null;
              _existingImageUrl = null;
            }),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
            label: const Text('Remove image', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImageBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(_selectedImageBytes!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () => setState(() { _selectedImageBytes = null; _selectedImageName = null; }),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    if (_existingImageUrl != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _existingImageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.local_offer, size: 64, color: AppColors.primaryLaurel)),
            ),
          ),
          Positioned(
            bottom: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
              child: const Text('Tap to change', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 64, color: AppColors.textSecondaryHintColor),
          SizedBox(height: 16),
          Text('Click to upload promo image', style: TextStyle(color: AppColors.textSecondaryHintColor, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => context.go(RouteEndpoint.promos),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.borderColor),
            ),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryColor)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLaurel,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Update Promo', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
