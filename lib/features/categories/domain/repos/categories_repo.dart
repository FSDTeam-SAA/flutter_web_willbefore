import '../models/category_model.dart';
import '../requests/create_category_request.dart';
import '../requests/update_category_request.dart';

abstract class CategoriesRepository {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory(CreateCategoryRequest request);
  Future<CategoryModel> updateCategory(UpdateCategoryRequest request);
  Future<void> deleteCategory(String id);
  Stream<List<CategoryModel>> getCategoriesStream();
}