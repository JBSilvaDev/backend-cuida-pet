import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/view_models/refresh_token_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/update_url_avatar_view.dart';
import 'package:cuidapet_api/modules/user/view_models/user_refres_token_imput_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_save_input.dart';
import 'package:cuidapet_api/modules/user/view_models/user_update_token_device_input_model.dart';
import '../view_models/user_confirm_input_model.dart';

abstract class IUserService {
  Future<User> createUser(UserSaveInputModel user);
  Future<User> loginWithEmailPassword(
      String email, String password, bool supplierUser);
  Future<User> loginWithSocial(
      String email, String? avatar, String socialType, String socialKey);
  Future<String> confirmLogin(UserConfirmInputModel inputModel);
  Future<RefreshTokenViewModel> refreshToken(UserRefresTokenImputModel model);
  Future<User> findById(int id);
  Future<User> updateAvatar(UpdateUrlAvatarView viewModel);
  Future<void> updateDeviceToken(UserUpdateTokenDeviceInputModel model);
}
