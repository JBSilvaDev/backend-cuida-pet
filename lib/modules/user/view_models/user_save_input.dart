// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../../app/helpers/request_map.dart';

class UserSaveInputModel extends RequestMap {
  late String email;
  late String password;
  int? supplierId;
    UserSaveInputModel.requestMapping(String dataRequest) : super(dataRequest);
  UserSaveInputModel({
    required this.email,
    required this.password,
    this.supplierId,
  }): super.empty();


  

  @override
  void map() {
    email = data['email'];
    password = data['password'];
  }
}
