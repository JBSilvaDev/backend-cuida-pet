import 'package:cuidapet_api/dtos/supplier_near_by_mr_dto.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';

import '../../../entities/supplier.dart';

abstract class ISupplierRepository {
  Future<List<SupplierNearByMrDto>> findNearByPosition(
      double lat, double long, int distance);
  Future<Supplier?> findById(int id);
  Future<List<SupplierService>> findServicesBySupplierId(int supplierId);
  Future<bool> checkUserExistis(String email);
  Future<int> saveSuppliert(Supplier supplier);
  Future<Supplier> update(Supplier supplier);
  
  
  
}
