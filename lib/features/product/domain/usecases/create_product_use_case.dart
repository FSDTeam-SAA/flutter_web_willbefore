
import '../entrity/product.dart';
import '../repos/product_repository.dart';
import '../requests/create_product_request.dart';

class CreateProductUseCase {
  final ProductsRepository _repository;

  CreateProductUseCase(this._repository);

  Future<Product> call(CreateProductRequest request) async {
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
    
    if (request.images.isEmpty) {
      throw Exception('Product must have at least one image');
    }
    
    if (request.categoryId.trim().isEmpty) {
      throw Exception('Product must have a category');
    }

    return await _repository.createProduct(request);
  }
}
