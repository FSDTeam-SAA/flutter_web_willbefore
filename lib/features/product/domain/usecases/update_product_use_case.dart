import '../entrity/product.dart';
import '../repos/product_repository.dart';
import '../requests/update_product_request.dart';

class UpdateProductUseCase {
  final ProductsRepository _repository;

  UpdateProductUseCase(this._repository);

  Future<Product> call(UpdateProductRequest request) async {
    // Validate request
    if (request.title.trim().isEmpty) {
      throw Exception('Product title cannot be empty');
    }
    
    if (request.actualPrice <= 0) {
      throw Exception('Product price must be greater than 0');
    }
    
    if (request.stock < 0) {
      throw Exception('Product stock cannot be negative');
    }
    
    final totalImages = request.newImages.length + request.existingImageUrls.length;
    if (totalImages == 0) {
      throw Exception('Product must have at least one image');
    }
    
    if (request.categoryId.trim().isEmpty) {
      throw Exception('Product must have a category');
    }

    return await _repository.updateProduct(request);
  }
}
