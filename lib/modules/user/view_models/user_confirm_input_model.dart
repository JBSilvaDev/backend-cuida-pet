// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/helpers/request_map.dart';

import '../../../app/exceptions/request_validation_exception.dart';

class UserConfirmInputModel extends RequestMap {
  int userId;
  String accessToken;
  String? iosDeviceToken;
  String? androidDeviceToken;
  UserConfirmInputModel(
      {required this.userId, required this.accessToken, required String data})
      : super(data);

  @override
  void map() {
    iosDeviceToken = data['ios_token'];
    androidDeviceToken = data['android_token'];
  }

  void validadeRequestConfirm() {
    final errors = <String, String>{};

    if (iosDeviceToken == null && androidDeviceToken == null) {
      errors['ios_token'] = 'required';
      errors['android_token'] = 'required';
    }

    if (errors.isNotEmpty) {
      throw RequestValidationException(errors: errors);
    }
  }
}
