import 'package:cuidapet_api/app/helpers/request_map.dart';
import 'package:cuidapet_api/modules/user/view_models/platform_enum.dart';

class UserUpdateTokenDeviceInputModel extends RequestMap {
  int userId;
  late String token;
  late PlatformEnum platform;

  UserUpdateTokenDeviceInputModel({
    required String dataRequest,
    required this.userId,
  }) : super(dataRequest);

  @override
  void map() {
    token = data['token'];
    platform = (data['platform'].toUpperCase() == 'IOS' ? PlatformEnum.ios : PlatformEnum.android);
    
  }
}
