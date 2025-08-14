import '../repos/categories_repo.dart';

class DeleteCategoryUseCase {
  final CategoriesRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteCategory(id);
  }
}