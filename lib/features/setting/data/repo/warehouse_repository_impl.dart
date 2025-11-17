// features/warehouse/data/repos/warehouse_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/warehouse_address.dart';
import '../../domain/repo/warehouse_repository.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final FirebaseFirestore _firestore;

  WarehouseRepositoryImpl(this._firestore);

  @override
  Future<WarehouseAddress?> getAddress() async {
    final doc = await _firestore
        .collection('settings')
        .doc('warehouse_address')
        .get();

    if (!doc.exists) return null;
    return WarehouseAddress.fromJson(doc.data()!);
  }

  @override
  Future<void> saveAddress(WarehouseAddress address) async {
    await _firestore
        .collection('settings')
        .doc('warehouse_address')
        .set(address.toJson(), SetOptions(merge: true));
  }
}

// Provider
final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepositoryImpl(FirebaseFirestore.instance);
});