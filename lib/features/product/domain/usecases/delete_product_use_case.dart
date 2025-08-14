import '../repos/product_repository.dart';

class DeleteProductUseCase {
  final ProductsRepository _repository;

  DeleteProductUseCase(this._repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    return await _repository.deleteProduct(id);
  }
}

class UpdateProductStockUseCase {
  final ProductsRepository _repository;

  UpdateProductStockUseCase(this._repository);

  Future<void> call(String id, int newStock) async {
    if (id.trim().isEmpty) {
      throw Exception('Product ID cannot be empty');
    }
    
    if (newStock < 0) {
      throw Exception('Stock cannot be negative');
    }

    return await _repository.updateProductStock(id, newStock);
  }
}

class ToggleProductStatusUseCase {
  final ProductsRepository _repository;

  ToggleProductStatusUseCase(this._repository);

  Future<void> call(String id, bool isActive) async {
    if (id.trim().isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    return await _repository.toggleProductStatus(id, isActive);
  }
}
