import 'dart:typed_data';

class UpdatePromoRequest {
  final String id;
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
  final String? existingImageUrl;
  final bool isActive;
  final int usageLimit;
  final List<String> applicableProductIds;
  final List<String> applicableCategoryIds;

  UpdatePromoRequest({
    required this.id,
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
    this.existingImageUrl,
    this.isActive = true,
    this.usageLimit = 0,
    this.applicableProductIds = const [],
    this.applicableCategoryIds = const [],
  });
}