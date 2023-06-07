import 'package:cuidapet_api/app/helpers/request_map.dart';

class UpdateUrlAvatarView extends RequestMap {
  late String urlAvatar;
  int userId;

  UpdateUrlAvatarView({required this.userId, required String dataRequest})
      : super(dataRequest);

  @override
  void map() {
    urlAvatar = data['url_avatar'];
  }
}
