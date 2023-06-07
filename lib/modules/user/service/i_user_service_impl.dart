// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/helpers/jwt_helper.dart';
import 'package:cuidapet_api/modules/user/view_models/refresh_token_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/update_url_avatar_view.dart';
import 'package:cuidapet_api/modules/user/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_refres_token_imput_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_update_token_device_input_model.dart';
import 'package:injectable/injectable.dart';

import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/user/view_models/user_save_input.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../../../app/exceptions/service_exception.dart';
import '../../../app/exceptions/user_exeptions.dart';
import './i_user_service.dart';

@LazySingleton(as: IUserService)
class IUserServiceImpl implements IUserService {
  IUserRepository userRepository;
  ILogger log;

  IUserServiceImpl({
    required this.userRepository,
    required this.log,
  });

  @override
  Future<User> createUser(UserSaveInputModel user) {
    final userEntity = User(
      email: user.email,
      password: user.password,
      registerType: 'App',
      supplierId: user.supplierId,
    );
    return userRepository.createUser(userEntity);
  }

  @override
  Future<User> loginWithEmailPassword(
      String email, String password, bool supplierUser) {
    return userRepository.loginWithEmailPassword(email, password, supplierUser);
  }

  @override
  Future<User> loginWithSocial(
      String email, String avatar, String socialType, String socialKey) async {
    try {
      return await userRepository.loginBySocialKey(
          email, socialKey, socialType);
    } on UserNotFoundException catch (e) {
      log.error('Usuario nao encontrado, criando um usuario', e);
      final user = User(
        email: email,
        imageAvatar: avatar,
        registerType: socialType,
        socialKey: socialKey,
        password: DateTime.now().toString(),
      );

      return await userRepository.createUser(user);
    }
  }

  @override
  Future<String> confirmLogin(UserConfirmInputModel inputModel) async {
    final refreshToken = JwtHelper.refreshToken(inputModel.accessToken);
    final user = User(
        id: inputModel.userId,
        refreshToken: refreshToken,
        iosToken: inputModel.iosDeviceToken,
        androidToken: inputModel.androidDeviceToken);

    await userRepository.updateUserAndRefreshToken(user);
    return refreshToken;
  }

  @override
  Future<RefreshTokenViewModel> refreshToken(
      UserRefresTokenImputModel model) async {
    _validadeRefreshToken(model);
    final newAccessToken = JwtHelper.gerenateJWT(model.user, model.supplier);
    final newRefreshToken =
        JwtHelper.refreshToken(newAccessToken.replaceAll('Bearer ', ''));
    final user = User(id: model.user, refreshToken: newRefreshToken);
    await userRepository.updateRefreshToken(user);

    return RefreshTokenViewModel(
        accessToken: newAccessToken, refreshToken: newRefreshToken);
  }

  void _validadeRefreshToken(UserRefresTokenImputModel model) {
    try {
      final refreshToken = model.refreshToken.split(' ');
      if (refreshToken.length != 2 || refreshToken.first != 'Bearer') {
        print(refreshToken.length);
        print(refreshToken.first);
        log.error('Refresh token invalido');
        throw ServiceException('Refresh token invalido');
      }
      final refreshTokenClaim = JwtHelper.getClaims(refreshToken.last);
      refreshTokenClaim.validate(issuer: model.accessToken);
    } on ServiceException {
      rethrow;
    } on JwtException catch (e) {
      log.error('Refresh token invalido', e);
      throw ServiceException('Refresh token invalido');
    } catch (e) {
      throw ServiceException('Erro ao validar refresh token');
    }
  }

  @override
  Future<User> findById(int id) => userRepository.findById(id);

  @override
  Future<User> updateAvatar(UpdateUrlAvatarView viewModel) async {
    await userRepository.updateUrlAvatar(viewModel.userId, viewModel.urlAvatar);
    return findById(viewModel.userId);
  }

  @override
  Future<void> updateDeviceToken(UserUpdateTokenDeviceInputModel model) =>
      userRepository.updateDeviceToken(
        model.userId,
        model.token,
        model.platform,
      );
}
