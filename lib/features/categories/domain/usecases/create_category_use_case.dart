import '../models/category_model.dart';
import '../repos/categories_repo.dart';
import '../requests/create_category_request.dart';

class CreateCategoryUseCase {
  final CategoriesRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<CategoryModel> call(CreateCategoryRequest request) async {
    return await repository.createCategory(request);
  }
}