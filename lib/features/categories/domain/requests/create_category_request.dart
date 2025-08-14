import 'dart:typed_data';

class CreateCategoryRequest {
  final String name;
  final Uint8List? imageBytes;
  final String? imageName;

  CreateCategoryRequest({
    required this.name,
    this.imageBytes,
    this.imageName,
  });
}