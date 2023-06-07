// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_save_input.dart';
import 'package:injectable/injectable.dart';

import 'package:cuidapet_api/dtos/supplier_near_by_mr_dto.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
import 'package:cuidapet_api/modules/supplier/data/i_supplier_repository.dart';
import 'package:cuidapet_api/modules/supplier/view_models/create_supplier_user_view_model.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';

import '../../../entities/category.dart';
import './i_supplier_service.dart';

@LazySingleton(as: ISupplierService)
class ISupplierServiceImpl implements ISupplierService {
  final ISupplierRepository repository;
  final IUserService userService;
  static const DISTANCE = 5;
  ISupplierServiceImpl({
    required this.repository,
    required this.userService,
  });
  @override
  Future<List<SupplierNearByMrDto>> findNearByMe(double lat, double long) {
    return repository.findNearByPosition(lat, long, DISTANCE);
  }

  @override
  Future<Supplier?> findById(int id) => repository.findById(id);

  @override
  Future<List<SupplierService>> findServiceBySupplier(int supplierId) =>
      repository.findServicesBySupplierId(supplierId);

  @override
  Future<bool> checkUserExistis(String email) =>
      repository.checkUserExistis(email);

  @override
  Future<void> createUserSupplier(CreateSupplierUserViewModel model) async {
    final supplierMEntity = Supplier(
      name: model.supplierName,
      category: Category(id: model.category),
    );
    final supplierId = await repository.saveSuppliert(supplierMEntity);
    final userImputModel = UserSaveInputModel(
      email: model.email,
      password: model.password,
      supplierId: supplierId,
    );
    await userService.createUser(userImputModel);
  }

  @override
  Future<Supplier> update(SupplierUpdateInputModel model) async {
    var supplier = Supplier(
      id: model.supplierId,
      name: model.name,
      address: model.address,
      lat: model.lat,
      long: model.long,
      logo: model.logo,
      phone: model.phone,
      category: Category(id: model.categoryId)
    );
    return await repository.update(supplier);

  }
}
