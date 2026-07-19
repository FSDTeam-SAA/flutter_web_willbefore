import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';

class ShippingState {
  final double? flatRate;
  final bool isLoading;
  final String? error;

  ShippingState({this.flatRate, this.isLoading = false, this.error});

  ShippingState copyWith({double? flatRate, bool? isLoading, String? error}) {
    return ShippingState(
      flatRate: flatRate ?? this.flatRate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final shippingProvider =
    StateNotifierProvider<ShippingNotifier, ShippingState>((ref) {
  return ShippingNotifier();
});

class ShippingNotifier extends StateNotifier<ShippingState> {
  ShippingNotifier() : super(ShippingState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('shipping')
          .get();
      final rate = doc.exists ? (doc.data()?['flatRate'] as num?)?.toDouble() : null;
      state = state.copyWith(flatRate: rate, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<bool> save(double flatRate) async {
    state = state.copyWith(isLoading: true);
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('shipping')
          .set({'flatRate': flatRate}, SetOptions(merge: true));
      state = state.copyWith(flatRate: flatRate, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}
