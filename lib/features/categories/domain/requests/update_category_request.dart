import 'dart:typed_data';

class UpdateCategoryRequest {
  final String id;
  final String name;
  final Uint8List? imageBytes;
  final String? imageName;
  final String? existingImageUrl;

  UpdateCategoryRequest({
    required this.id,
    required this.name,
    this.imageBytes,
    this.imageName,
    this.existingImageUrl,
  });
}