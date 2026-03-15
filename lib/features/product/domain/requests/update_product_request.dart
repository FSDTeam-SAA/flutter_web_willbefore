import 'dart:typed_data';

class UpdateProductRequest {
  final String id;
  final String title;
  final String description;
  final double actualPrice;
  final double? discountPrice;
  final int stock;
  final String categoryId;
  final String? promoId;
  final List<String> sizes;
  final List<String> colors;
  final List<String> colorCodes;
  final List<ProductImageData> newImages;
  final List<String> existingImageUrls;
  final bool isActive;
  final Map<String, dynamic>? facilities;

  const UpdateProductRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.actualPrice,
    this.discountPrice,
    required this.stock,
    required this.categoryId,
    this.promoId,
    required this.sizes,
    required this.colors,
    required this.colorCodes,
    required this.newImages,
    required this.existingImageUrls,
    required this.isActive,
    this.facilities,
  });
}

class ProductImageData {
  final Uint8List bytes;
  final String name;

  const ProductImageData({
    required this.bytes,
    required this.name,
  });
}
