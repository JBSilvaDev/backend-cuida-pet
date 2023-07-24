import 'dart:convert';

import 'package:cuidapet_api/app/helpers/jwt_helper.dart';
import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/app/middlewares/middlewares.dart';
import 'package:cuidapet_api/app/middlewares/security/security_skip_url.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

class SecurityMiddleware extends Middlewares {

  final ILogger log;

  final skypUrl = <SecuritySkipUrl>[
    SecuritySkipUrl(url: '/auth/register/', method: 'POST'),
    SecuritySkipUrl(url: '/auth/', method: 'POST'),
    SecuritySkipUrl(url: '/suppliers/user', method: 'GET'),
    SecuritySkipUrl(url: '/suppliers/user', method: 'POST'),
  ];
  
  SecurityMiddleware(this.log);

  @override
  Future<Response> execute(Request request) async {
    try {
      if (skypUrl.contains(SecuritySkipUrl(
          url: '/${request.url.path}', method: request.method))) {
        return innerHandler(request);
      }
      final authHeader = request.headers['Authorization'];
      
      if (authHeader == null || authHeader.isEmpty) {
        throw JwtException.invalidToken;
      }
      final authHeaderContent = authHeader.split(' ');
      if (authHeaderContent[0] != 'Bearer') {
        throw JwtException.invalidToken;
      }

      final authToken = authHeaderContent[1];

      final claims = JwtHelper.getClaims(authToken);

      if (request.url.path != 'auth/refresh') {
        claims.validate();
      }

      final claimsMap = claims.toJson();

      final userId = claimsMap['sub'];
      final supplierId = claimsMap['supplier'];

      if (userId == null) {
        throw JwtException.invalidToken;
      }
      final securityHeaders = {
        'user': userId,
        'access_token': authToken,
        'supplier': supplierId != null ? '$supplierId' :null
      };
      return innerHandler(request.change(headers: securityHeaders));
    } on JwtException catch (e, s) {
      log.error('Erro ao validar token JWT', e, s);
      return Response.forbidden(jsonEncode({}));
    } catch (e, s) {
      log.error('Internal server error token JWT', e, s);
      return Response.forbidden(jsonEncode({}));
    }
  }
}
