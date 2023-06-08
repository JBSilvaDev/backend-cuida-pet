import 'dart:io';

import 'package:cuidapet_api/app/config/app_config.dart';
import 'package:cuidapet_api/app/middlewares/defaultContentType/default_content_type.dart';
import 'package:cuidapet_api/app/middlewares/security/security_middleware.dart';
import 'package:get_it/get_it.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:cuidapet_api/app/middlewares/cors/cors_middlerwares.dart';

final _router = Router();

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = '0.0.0.0';

  // App Config
  final appConfig = AppConfig();
  await appConfig.loadConfigApplication(_router);

  final getIt = GetIt.I;

  // Configure a pipeline that logs requests.
  // final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);
  final handler = Pipeline()
  .addMiddleware(CorsMiddlerwares().handler)
  .addMiddleware(DefaultContentType('application/json;charset=utf-8').handler)
  .addMiddleware(SecurityMiddleware(getIt.get()).handler)
  .addMiddleware(logRequests())
  .addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('''
Server iniciado na porta ${server.port}\n
Para acessar usar um dos endereços abaixo: 
  http://0.0.0.0:${server.port}\n
  http://localhost:${server.port}\n
  http://<seu-ip>:${server.port}\n
''');
  
}
