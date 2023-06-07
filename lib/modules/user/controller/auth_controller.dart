// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:cuidapet_api/app/helpers/jwt_helper.dart';
import 'package:cuidapet_api/modules/user/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_refres_token_imput_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_api/modules/user/view_models/user_save_input.dart';

import '../../../app/exceptions/user_exeptions.dart';
import '../../../entities/user.dart';
import '../view_models/login_view_model.dart';

part 'auth_controller.g.dart';

@Injectable()
class AuthController {
  IUserService userService;
  ILogger log;

  AuthController({
    required this.userService,
    required this.log,
  });
  @Route.post('/')
  Future<Response> login(Request request) async {
    try {
      final loginViewModel = LoginViewModel(await request.readAsString());

      User user;

      if (!loginViewModel.socialLogin) {
        user = await userService.loginWithEmailPassword(loginViewModel.login,
            loginViewModel.password, loginViewModel.supplierUser);
      } else {
        user = await userService.loginWithSocial(
          loginViewModel.login,
          loginViewModel.avatar,
          loginViewModel.socialType,
          loginViewModel.socialKey,
        );
      }
      return Response.ok(jsonEncode(
          {'access_token': JwtHelper.gerenateJWT(user.id!, user.supplierId)}));
    } on UserNotFoundException {
      return Response(400,body: jsonEncode({'message': 'Usuario ou senha invalidos'}));
    } catch (e, s) {
      log.error('Erro ou fazer login', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao realizar login'}));
    }
  }

  @Route.post('/register')
  Future<Response> saveUser(Request request) async {
    try {
      final userModel = UserSaveInputModel.requestMapping(await request.readAsString());

      await userService.createUser(userModel);

      return Response.ok(
          jsonEncode({'message': 'cadastro realizado com sucesso'}));
    } on UserExistsException {
      return Response( 400,body:jsonEncode({'message': 'Usuario ja cadastrado'}));
    } catch (e, s) {
      log.error('Erro ao cadastrar usuarios', e, s);
      return Response.internalServerError();
    }
  }

  @Route('PATCH', '/confirm')
  Future<Response> confirmLogin(Request request) async {
    final user = int.parse(request.headers['user']!);
    final supplier = int.tryParse(request.headers['supplier'] ?? '');
    final token =
        JwtHelper.gerenateJWT(user, supplier).replaceAll('Bearer ', '');

    final inputModel = UserConfirmInputModel(
        userId: user, accessToken: token, data: await request.readAsString());

    final refreshToken = await userService.confirmLogin(inputModel);
    return Response.ok(
        jsonEncode({'access_token': 'Bearer $token', 'refresh_token': refreshToken}));
  }

  @Route.put('/refresh')
  Future<Response> refreshToken(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final supplier = int.tryParse(request.headers['supplier'] ?? '');
      final accessToken = request.headers['access_token']!;
      final model = UserRefresTokenImputModel(
        user: user,
        supplier: supplier,
        accessToken: accessToken,
        dataRequest: await request.readAsString(),
      );
      final userRefreshToken = await userService.refreshToken(model);
      return Response.ok(jsonEncode({
        'access_token': userRefreshToken.accessToken,
        'refresh_token': userRefreshToken.refreshToken
      }));
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao atualizar access token'}));
    }
  }

  Router get router => _$AuthControllerRouter(this);
}
