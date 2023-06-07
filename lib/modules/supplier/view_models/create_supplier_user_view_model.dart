// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/helpers/request_map.dart';

class CreateSupplierUserViewModel extends RequestMap {
  late String supplierName;
  late String email;
  late String password;
  late int category;
  CreateSupplierUserViewModel({
    required String dataRequest,
  }) : super(dataRequest);

  @override
  void map() {
    supplierName = data['supplier_name'];
    email = data['email'];

    password = data['password'];
    category = data['category_id'];
  }
}
