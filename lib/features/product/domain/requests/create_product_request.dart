import 'dart:typed_data';

class CreateProductRequest {
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
  final List<ProductImageData> images;
  final double? overOrderDiscount;
  final int? freeReturnDays;
  final Map<String, dynamic>? facilities;

  CreateProductRequest({
    required this.title,
    required this.description,
    required this.actualPrice,
    this.discountPrice,
    required this.stock,
    required this.categoryId,
    this.promoId,
    this.sizes = const [],
    this.colors = const [],
    this.colorCodes = const [],
    this.images = const [],
    this.overOrderDiscount,
    this.freeReturnDays,
    this.facilities,
  });
}

class ProductImageData {
  final Uint8List bytes;
  final String name;

  ProductImageData({
    required this.bytes,
    required this.name,
  });
}