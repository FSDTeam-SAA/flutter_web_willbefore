import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_willbefore/core/base/base_state.dart';

import '../../data/repos/promos_repository_impl.dart';
import '../../domain/models/promo_model.dart';
import '../../domain/requests/create_promo_request.dart';
import '../../domain/requests/update_promo_request.dart';
import '../../domain/usecases/create_promo_use_case.dart';
import '../../domain/usecases/delete_promo_use_case.dart';
import '../../domain/usecases/get_promo_use_case.dart';
import '../../domain/usecases/update_promo_use_case.dart';

class PromosState extends BaseState {
  final List<PromoModel> promos;
  final List<PromoModel> activePromos;
  final PromoModel? selectedPromo;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const PromosState({
    super.isLoading = false,
    super.errorMessage,
    this.promos = const [],
    this.activePromos = const [],
    this.selectedPromo,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  @override
  PromosState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PromoModel>? promos,
    List<PromoModel>? activePromos,
    PromoModel? selectedPromo,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return PromosState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      promos: promos ?? this.promos,
      activePromos: activePromos ?? this.activePromos,
      selectedPromo: selectedPromo ?? this.selectedPromo,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

final promosProvider = StateNotifierProvider<PromosProvider, PromosState>((ref) {
  final repository = ref.watch(promosRepositoryProvider);
  final getPromosUseCase = GetPromosUseCase(repository);
  final createPromoUseCase = CreatePromoUseCase(repository);
  final updatePromoUseCase = UpdatePromoUseCase(repository);
  final deletePromoUseCase = DeletePromoUseCase(repository);

  return PromosProvider(
    getPromosUseCase,
    createPromoUseCase,
    updatePromoUseCase,
    deletePromoUseCase,
  );
});

class PromosProvider extends StateNotifier<PromosState> {
  final GetPromosUseCase _getPromosUseCase;
  final CreatePromoUseCase _createPromoUseCase;
  final UpdatePromoUseCase _updatePromoUseCase;
  final DeletePromoUseCase _deletePromoUseCase;

  PromosProvider(
    this._getPromosUseCase,
    this._createPromoUseCase,
    this._updatePromoUseCase,
    this._deletePromoUseCase,
  ) : super(const PromosState()) {
    loadPromos();
    _listenToPromos();
  }

  void _listenToPromos() {
    _getPromosUseCase.stream().listen(
      (promos) {
        final activePromos = promos.where((promo) => promo.isCurrentlyActive).toList();
        state = state.copyWith(
          promos: promos,
          activePromos: activePromos,
          isLoading: false,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> loadPromos() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final promos = await _getPromosUseCase.call();
      final activePromos = await _getPromosUseCase.getActive();
      state = state.copyWith(
        promos: promos,
        activePromos: activePromos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createPromo(CreatePromoRequest request) async {
    state = state.copyWith(isCreating: true, errorMessage: null);
    try {
      await _createPromoUseCase.call(request);
      state = state.copyWith(isCreating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isCreating: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updatePromo(UpdatePromoRequest request) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);
    try {
      await _updatePromoUseCase.call(request);
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deletePromo(String id) async {
    state = state.copyWith(isDeleting: true, errorMessage: null);
    try {
      await _deletePromoUseCase.call(id);
      state = state.copyWith(isDeleting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
      return false;
    }
  }

  void setSelectedPromo(PromoModel? promo) {
    state = state.copyWith(selectedPromo: promo);
  }

  Future<PromoModel?> validatePromoCode(String code) async {
    try {
      final promo = await _getPromosUseCase.getByCode(code);
      if (promo != null && promo.isCurrentlyActive) {
        return promo;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}