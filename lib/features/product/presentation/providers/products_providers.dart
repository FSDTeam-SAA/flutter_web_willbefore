import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../data/repos/products_repository_impl.dart';
import '../../data/sources/products_remote_data_source.dart';
import '../../domain/entrity/product.dart';
import '../../domain/requests/create_product_request.dart';
import '../../domain/requests/update_product_request.dart';
import '../../domain/usecases/create_product_use_case.dart';
import '../../domain/usecases/delete_product_use_case.dart';
import '../../domain/usecases/get_products_use_case.dart';
import '../../domain/usecases/update_product_use_case.dart';

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final GetProductsUseCase _getProductsUseCase;
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  ProductsNotifier(
    this._getProductsUseCase,
    this._createProductUseCase,
    this._updateProductUseCase,
    this._deleteProductUseCase,
  ) : super(const ProductsState()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final products = await _getProductsUseCase.call();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createProduct(CreateProductRequest request) async {
    state = state.copyWith(isCreating: true, errorMessage: null);

    try {
      final newProduct = await _createProductUseCase.call(request);

      final updatedProducts = [newProduct, ...state.products];
      state = state.copyWith(products: updatedProducts, isCreating: false);

      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(UpdateProductRequest request) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      final updatedProduct = await _updateProductUseCase.call(request);

      // Update the product in the list
      final updatedProducts = state.products.map((product) {
        return product.id == updatedProduct.id ? updatedProduct : product;
      }).toList();

      state = state.copyWith(products: updatedProducts, isUpdating: false);

      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    state = state.copyWith(isDeleting: true, errorMessage: null);

    try {
      await _deleteProductUseCase.call(productId);

      // Remove the product from the list
      final updatedProducts = state.products
          .where((product) => product.id != productId)
          .toList();

      state = state.copyWith(products: updatedProducts, isDeleting: false);

      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Products Provider with direct dependency creation
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    // Create dependencies directly
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    final remoteDataSource = ProductsRemoteDataSourceImpl(firestore);
    final repository = ProductsRepositoryImpl(remoteDataSource, storage);

    final getProductsUseCase = GetProductsUseCase(repository);
    final createProductUseCase = CreateProductUseCase(repository);
    final updateProductUseCase = UpdateProductUseCase(repository);
    final deleteProductUseCase = DeleteProductUseCase(repository);

    return ProductsNotifier(
      getProductsUseCase,
      createProductUseCase,
      updateProductUseCase,
      deleteProductUseCase,
    );
  },
);
