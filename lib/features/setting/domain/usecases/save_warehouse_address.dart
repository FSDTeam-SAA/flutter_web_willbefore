// features/warehouse/domain/usecases/save_warehouse_address.dart
import '../../domain/models/warehouse_address.dart';
import '../repo/warehouse_repository.dart';

class SaveWarehouseAddress {
  final WarehouseRepository _repo;
  SaveWarehouseAddress(this._repo);

  Future<void> call(WarehouseAddress address) => _repo.saveAddress(address);
}

// features/warehouse/domain/usecases/get_warehouse_address.dart
class GetWarehouseAddress {
  final WarehouseRepository _repo;
  GetWarehouseAddress(this._repo);

  Future<WarehouseAddress?> call() => _repo.getAddress();
}
