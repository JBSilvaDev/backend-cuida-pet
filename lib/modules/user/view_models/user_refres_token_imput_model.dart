import 'package:cuidapet_api/app/helpers/request_map.dart';

class UserRefresTokenImputModel extends RequestMap {
  int user;
  int? supplier;
  String accessToken;
  late String refreshToken;

  UserRefresTokenImputModel({
    required this.user,
    this.supplier,
    required this.accessToken,
    required String dataRequest,
  }) : super(dataRequest);
  @override
  void map() {
    refreshToken = data['refresh_token'];
  }
}
