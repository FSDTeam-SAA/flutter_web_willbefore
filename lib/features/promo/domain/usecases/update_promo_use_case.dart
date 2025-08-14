import '../models/promo_model.dart';
import '../repos/promo_reposotory.dart';
import '../requests/update_promo_request.dart';

class UpdatePromoUseCase {
  final PromosRepository repository;

  UpdatePromoUseCase(this.repository);

  Future<PromoModel> call(UpdatePromoRequest request) async {
    // Validate promo code uniqueness (excluding current promo)
    final existingPromo = await repository.getPromoByCode(request.code);
    if (existingPromo != null && existingPromo.id != request.id) {
      throw Exception('Promo code already exists');
    }

    // Validate dates
    if (request.endDate.isBefore(request.startDate)) {
      throw Exception('End date must be after start date');
    }

    return await repository.updatePromo(request);
  }
}