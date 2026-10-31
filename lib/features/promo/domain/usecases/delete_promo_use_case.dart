import '../repos/promo_reposotory.dart';

class DeletePromoUseCase {
  final PromosRepository repository;

  DeletePromoUseCase(this.repository);

  Future<void> call(String id) async {
    // Deleting would leave these products pointing at a missing promo
    final linkedProducts = await repository.countProductsUsingPromo(id);
    if (linkedProducts > 0) {
      throw Exception(
        'This promo is linked to $linkedProducts '
        '${linkedProducts == 1 ? 'product' : 'products'}. '
        'Unlink it first.',
      );
    }

    return await repository.deletePromo(id);
  }
}
