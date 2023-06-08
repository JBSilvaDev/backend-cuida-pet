import 'package:cuidapet_api/app/exceptions/request_validation_exception.dart';
import 'package:cuidapet_api/app/helpers/request_map.dart';

class LoginViewModel extends RequestMap {
  late String login;
  String? password;
  late bool socialLogin;
  String? avatar;
  String? socialType;
  String? socialKey;
  late bool supplierUser;

  LoginViewModel(String dataRequest) : super(dataRequest);

  @override
  void map() {
    login = data['login'];
    password = data['password'];
    socialLogin = data['social_login'];
    avatar = data['avatar'] ??
        "https://avatars.githubusercontent.com/u/75276203?v=4";
    socialType = data['social_type'];
    socialKey = data['social_key'];
    supplierUser = data['supplier_user'];
  }

  void loginEmailValidade() {
    final errors = <String, String>{};

    if (password == null) {
      errors['password'] = 'required';
    }
    if (errors.isNotEmpty) {
      throw RequestValidationException(errors: errors);
    }
  }

  void loginSocialValidade() {
    final errors = <String, String>{};

    if (socialType == null) {
      errors['social_type'] = 'required';
    }
    if (socialKey == null) {
      errors['social_key'] = 'required';
    }
    if (errors.isNotEmpty) {
      throw RequestValidationException(errors: errors);
    }
  }
}
