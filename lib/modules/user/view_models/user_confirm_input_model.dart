// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/helpers/request_map.dart';


class UserConfirmInputModel extends RequestMap {
  int userId;
  String accessToken;
  late String iosDeviceToken;
  late String androidDeviceToken;
  UserConfirmInputModel(
      {required this.userId, required this.accessToken, required String data})
      : super(data);

  @override
  void map() {
    iosDeviceToken = data['ios_token'] ?? '';
    androidDeviceToken = data['android_token'] ?? '';
  }
}
