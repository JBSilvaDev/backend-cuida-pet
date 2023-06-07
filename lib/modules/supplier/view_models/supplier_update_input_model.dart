// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/helpers/request_map.dart';

class SupplierUpdateInputModel extends RequestMap {
  int supplierId;
  late String name;
  late String logo;
  late String address;
  late String phone;
  late double lat;
  late double long;
  late int categoryId;
  SupplierUpdateInputModel(
      {required String dataRequest, required this.supplierId})
      : super(dataRequest);
  @override
  void map() {
    name = data['name'];
    logo = data['logo'];
    address = data['address'];
    phone = data['phone'];
    lat = data['lat'];
    long = data['long'];
    categoryId = data['category'];
  }
}
