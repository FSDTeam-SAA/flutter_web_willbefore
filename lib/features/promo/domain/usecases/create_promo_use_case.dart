import '../models/promo_model.dart';
import '../repos/promo_reposotory.dart';
import '../requests/create_promo_request.dart';

class CreatePromoUseCase {
  final PromosRepository repository;

  CreatePromoUseCase(this.repository);

  Future<PromoModel> call(CreatePromoRequest request) async {
    // Validate promo code uniqueness
    final existingPromo = await repository.getPromoByCode(request.code);
    if (existingPromo != null) {
      throw Exception('Promo code already exists');
    }

    // Validate dates
    if (request.endDate.isBefore(request.startDate)) {
      throw Exception('End date must be after start date');
    }

    return await repository.createPromo(request);
  }
}