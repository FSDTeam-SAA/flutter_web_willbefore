import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../../../core/theme/app_input_decoration.dart';
import '../../domain/models/promo_model.dart';
import '../../domain/requests/create_promo_request.dart';
import '../../domain/requests/update_promo_request.dart';
import '../providers/promos_provider.dart';
import '../widgets/promo_not_found.dart';

/// Creates a promo, or edits an existing one when [promoId] is given.
class AddPromoScreen extends ConsumerStatefulWidget {
  final String? promoId;

  const AddPromoScreen({super.key, this.promoId});

  @override
  ConsumerState<AddPromoScreen> createState() => _AddPromoScreenState();
}

class _AddPromoScreenState extends ConsumerState<AddPromoScreen> {
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
  bool _isActive = true;
  PromoModel? _editingPromo;

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

  /// Fills the form once, so a provider rebuild can't overwrite admin edits.
  void _prefillForm(PromoModel promo) {
    if (_editingPromo != null) return;
    _editingPromo = promo;

    final dateFormat = DateFormat('dd/MM/yyyy');
    _titleController.text = promo.title;
    _codeController.text = promo.code;
    _descriptionController.text = promo.description;
    _discountPercentageController.text = _formatNumber(
      promo.discountPercentage,
    );
    _discountAmountController.text = promo.discountAmount != null
        ? _formatNumber(promo.discountAmount!)
        : '';
    _minimumOrderController.text = promo.minimumOrderAmount != null
        ? _formatNumber(promo.minimumOrderAmount!)
        : '';
    _usageLimitController.text = promo.usageLimit.toString();
    _startDateController.text = dateFormat.format(promo.startDate);
    _endDateController.text = dateFormat.format(promo.endDate);
    _startDate = promo.startDate;
    _endDate = promo.endDate;
    _isActive = promo.isActive;
  }

  String _formatNumber(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final initialDate = (isStartDate ? _startDate : _endDate) ?? now;
    final latestDate = now.add(const Duration(days: 365));

    // An existing promo's dates can fall outside the usual range, and the
    // picker asserts that initialDate is within it.
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate.isBefore(now) ? initialDate : now,
      lastDate: initialDate.isAfter(latestDate) ? initialDate : latestDate,
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
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final code = _codeController.text.trim().toUpperCase();
    final description = _descriptionController.text.trim();
    final discountPercentage =
        double.tryParse(_discountPercentageController.text) ?? 0;
    final discountAmount = _discountAmountController.text.isNotEmpty
        ? double.tryParse(_discountAmountController.text)
        : null;
    final minimumOrderAmount = _minimumOrderController.text.isNotEmpty
        ? double.tryParse(_minimumOrderController.text)
        : null;
    final usageLimit = int.tryParse(_usageLimitController.text) ?? 0;

    final notifier = ref.read(promosProvider.notifier);
    final editingPromo = _editingPromo;

    final success = editingPromo == null
        ? await notifier.createPromo(
            CreatePromoRequest(
              title: title,
              code: code,
              description: description,
              discountPercentage: discountPercentage,
              discountAmount: discountAmount,
              minimumOrderAmount: minimumOrderAmount,
              startDate: _startDate!,
              endDate: _endDate!,
              imageBytes: _selectedImageBytes,
              imageName: _selectedImageName,
              isActive: _isActive,
              usageLimit: usageLimit,
            ),
          )
        : await notifier.updatePromo(
            UpdatePromoRequest(
              id: editingPromo.id,
              title: title,
              code: code,
              description: description,
              discountPercentage: discountPercentage,
              discountAmount: discountAmount,
              minimumOrderAmount: minimumOrderAmount,
              startDate: _startDate!,
              endDate: _endDate!,
              imageBytes: _selectedImageBytes,
              imageName: _selectedImageName,
              existingImageUrl: editingPromo.imageUrl,
              isActive: _isActive,
              usageLimit: usageLimit,
              applicableProductIds: editingPromo.applicableProductIds,
              applicableCategoryIds: editingPromo.applicableCategoryIds,
            ),
          );

    if (success && mounted) {
      context.go(RouteEndpoint.promos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editingPromo == null
                ? 'Promo created successfully!'
                : 'Promo updated successfully!',
          ),
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
    final promoId = widget.promoId;
    if (promoId == null) return _buildForm();

    return ref
        .watch(promoByIdProvider(promoId))
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryLaurel),
          ),
          error: (_, _) => const PromoNotFound(),
          data: (promo) {
            _prefillForm(promo);
            return _buildForm();
          },
        );
  }

  Widget _buildForm() {
    final promosState = ref.watch(promosProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 1000;
        final narrow = constraints.maxWidth < 600;

        final fields = [
          _buildPromoTitleSection(),
          const SizedBox(height: 24),
          _buildPromoCodeSection(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildDiscountSection(narrow),
          const SizedBox(height: 24),
          _buildDateSection(narrow),
          const SizedBox(height: 24),
          _buildSettingsSection(),
          const SizedBox(height: 32),
        ];
        final buttons = _buildActionButtons(
          promosState.isCreating || promosState.isUpdating,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(narrow ? 12 : 24),
          child: Form(
            key: _formKey,
            child: twoColumns
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [...fields, buttons],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right Column
                      Expanded(child: _buildImageSection(narrow)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...fields,
                      _buildImageSection(narrow),
                      const SizedBox(height: 32),
                      buttons,
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Two fields side by side, or stacked when [narrow].
  Widget _pair(bool narrow, Widget first, Widget second) {
    if (narrow) {
      return Column(children: [first, const SizedBox(height: 16), second]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second),
      ],
    );
  }

  Widget _buildPromoTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add promo title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: appInputDecoration(hintText: 'Enter promo title...'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a promo title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPromoCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _codeController,
          decoration: appInputDecoration(hintText: 'Enter promo code...'),
          onChanged: (value) {
            _codeController.value = _codeController.value.copyWith(
              text: value.toUpperCase(),
              selection: TextSelection.collapsed(offset: value.length),
            );
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a promo code';
            }
            if (value.length < 3) {
              return 'Promo code must be at least 3 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: appInputDecoration(
            hintText: 'Enter promo description...',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDiscountSection(bool narrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discount Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        _pair(
          narrow,
          TextFormField(
            controller: _discountPercentageController,
            decoration: appInputDecoration(
              labelText: 'Discount Percentage (%)',
              hintText: '0',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              final percentage = double.tryParse(value);
              if (percentage == null || percentage < 0 || percentage > 100) {
                return 'Enter valid percentage (0-100)';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _discountAmountController,
            decoration: appInputDecoration(
              labelText: 'Fixed Discount Amount',
              hintText: '0.00',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _minimumOrderController,
          decoration: appInputDecoration(
            labelText: 'Minimum Order Amount',
            hintText: '0.00',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDateSection(bool narrow) {
    return _pair(
      narrow,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textAppBlack,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _startDateController,
            readOnly: true,
            decoration: appInputDecoration(
              hintText: 'Enter start date...',
              suffixIcon: IconButton(
                onPressed: () => _selectDate(context, true),
                icon: const Icon(Icons.calendar_today),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select start date';
              }
              return null;
            },
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'End Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textAppBlack,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _endDateController,
            readOnly: true,
            decoration: appInputDecoration(
              hintText: 'Enter end date...',
              suffixIcon: IconButton(
                onPressed: () => _selectDate(context, false),
                icon: const Icon(Icons.calendar_today),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select end date';
              }
              if (_startDate != null &&
                  _endDate != null &&
                  _endDate!.isBefore(_startDate!)) {
                return 'End date must be after start date';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _usageLimitController,
          decoration: appInputDecoration(
            labelText: 'Usage Limit (0 for unlimited)',
            hintText: '0',
          ),
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
            const Text(
              'Active',
              style: TextStyle(
                color: AppColors.textAppBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection(bool narrow) {
    final existingImageUrl = _editingPromo?.imageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Promo Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: narrow ? 200 : 300,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.borderColor,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedImageBytes != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedImageBytes!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImageBytes = null;
                              _selectedImageName = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : existingImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      existingImageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_offer,
                        color: AppColors.primaryLaurel,
                        size: 64,
                      ),
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 64,
                          color: AppColors.textSecondaryHintColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Click to upload promo image',
                          style: TextStyle(
                            color: AppColors.textSecondaryHintColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : () => context.go(RouteEndpoint.promos),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.borderColor),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryColor),
            ),
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
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
