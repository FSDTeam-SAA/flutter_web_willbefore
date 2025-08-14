import '../repos/promo_reposotory.dart';

class DeletePromoUseCase {
  final PromosRepository repository;

  DeletePromoUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deletePromo(id);
  }
}