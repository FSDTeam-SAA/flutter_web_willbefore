// features/warehouse/domain/repos/warehouse_repository.dart
import '../models/warehouse_address.dart';

abstract class WarehouseRepository {
  Future<WarehouseAddress?> getAddress();
  Future<void> saveAddress(WarehouseAddress address);
}