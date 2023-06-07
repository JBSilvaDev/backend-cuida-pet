import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
import 'package:cuidapet_api/modules/supplier/view_models/create_supplier_user_view_model.dart';
import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';

import '../../../dtos/supplier_near_by_mr_dto.dart';

abstract class ISupplierService {
  Future<List<SupplierNearByMrDto>> findNearByMe(double lat, double long);
  Future<Supplier?> findById(int id);
  Future<List<SupplierService>> findServiceBySupplier(int supplierId);
  Future<bool> checkUserExistis(String email);
  Future<void> createUserSupplier(CreateSupplierUserViewModel model);
  Future<Supplier> update(SupplierUpdateInputModel model);

}
