import 'dart:typed_data';

class CreatePromoRequest {
  final String title;
  final String code;
  final String description;
  final double discountPercentage;
  final double? discountAmount;
  final double? minimumOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final Uint8List? imageBytes;
  final String? imageName;
  final bool isActive;
  final int usageLimit;
  final List<String> applicableProductIds;
  final List<String> applicableCategoryIds;

  CreatePromoRequest({
    required this.title,
    required this.code,
    required this.description,
    required this.discountPercentage,
    this.discountAmount,
    this.minimumOrderAmount,
    required this.startDate,
    required this.endDate,
    this.imageBytes,
    this.imageName,
    this.isActive = true,
    this.usageLimit = 0,
    this.applicableProductIds = const [],
    this.applicableCategoryIds = const [],
  });
}