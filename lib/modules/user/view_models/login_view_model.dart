import 'package:cuidapet_api/app/helpers/request_map.dart';

class LoginViewModel extends RequestMap {
  late String login;
  late String password;
  late bool socialLogin;
  late String avatar;
  late String socialType;
  late String socialKey;
  late bool supplierUser;

  LoginViewModel(String dataRequest) : super(dataRequest);

  @override
  void map() {
    login = data['login'];
    password = data['password'] ?? DateTime.now().toString();
    socialLogin = data['social_login'];
    avatar = data['avatar'] ??
        "https://avatars.githubusercontent.com/u/75276203?v=4";
    socialType = data['social_type'] ?? "APP";
    socialKey = data['social_key'] ?? "No Social Key";
    supplierUser = data['supplier_user'];
  }
}
