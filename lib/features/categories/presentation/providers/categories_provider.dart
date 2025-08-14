import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_willbefore/core/base/base_state.dart';


import '../../data/repos/categories_repo_impl.dart';
import '../../domain/models/category_model.dart';
import '../../domain/requests/create_category_request.dart';
import '../../domain/requests/update_category_request.dart';
import '../../domain/usecases/create_category_use_case.dart';
import '../../domain/usecases/delete_category_use_case.dart';
import '../../domain/usecases/get_category_use_case.dart';
import '../../domain/usecases/update_category_use_case.dart';

class CategoriesState extends BaseState {
  final List<CategoryModel> categories;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const CategoriesState({
    super.isLoading = false,
    super.errorMessage,
    this.categories = const [],
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  @override
  CategoriesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CategoryModel>? categories,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return CategoriesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

final categoriesProvider = StateNotifierProvider<CategoriesProvider, CategoriesState>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  final getCategoriesUseCase = GetCategoriesUseCase(repository);
  final createCategoryUseCase = CreateCategoryUseCase(repository);
  final updateCategoryUseCase = UpdateCategoryUseCase(repository);
  final deleteCategoryUseCase = DeleteCategoryUseCase(repository);

  return CategoriesProvider(
    getCategoriesUseCase,
    createCategoryUseCase,
    updateCategoryUseCase,
    deleteCategoryUseCase,
  );
});

class CategoriesProvider extends StateNotifier<CategoriesState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  CategoriesProvider(
    this._getCategoriesUseCase,
    this._createCategoryUseCase,
    this._updateCategoryUseCase,
    this._deleteCategoryUseCase,
  ) : super(const CategoriesState()) {
    loadCategories();
    _listenToCategories();
  }

  void _listenToCategories() {
    _getCategoriesUseCase.stream().listen(
      (categories) {
        state = state.copyWith(categories: categories, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final categories = await _getCategoriesUseCase.call();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createCategory(CreateCategoryRequest request) async {
    state = state.copyWith(isCreating: true, errorMessage: null);
    try {
      await _createCategoryUseCase.call(request);
      state = state.copyWith(isCreating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateCategory(UpdateCategoryRequest request) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      await _updateCategoryUseCase.call(request);
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    state = state.copyWith(isDeleting: true, errorMessage: null);
    try {
      await _deleteCategoryUseCase.call(id);
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
      return false;
    }
  }
}