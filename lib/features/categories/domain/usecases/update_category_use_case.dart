import '../models/category_model.dart';
import '../repos/categories_repo.dart';
import '../requests/update_category_request.dart';

class UpdateCategoryUseCase {
  final CategoriesRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<CategoryModel> call(UpdateCategoryRequest request) async {
    return await repository.updateCategory(request);
  }
}