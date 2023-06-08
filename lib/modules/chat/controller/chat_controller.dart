// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:cuidapet_api/modules/chat/view_models/chat_notify_view_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/modules/chat/service/i_chat_service.dart';

part 'chat_controller.g.dart';

@Injectable()
class ChatController {
  final ILogger log;
  final IChatService service;
  ChatController({
    required this.log,
    required this.service,
  });

  @Route.post('/schedule/<scheduleId>/start-chat')
  Future<Response> startChatByScheduleId(
      Request request, String scheduleId) async {
    try {
      final chatId = await service.startChat(int.parse(scheduleId));

      return Response.ok(jsonEncode({'chat_id': chatId}));
    } catch (e, s) {
      log.error('Erro ao iniciar chat', e, s);

      return Response.internalServerError();
    }
  }

  @Route.post('/notify')
  Future<Response> notifyUser(Request request) async {
    try {
      final model = ChatNotifyViewModel(await request.readAsString());
      await service.notifyChat(model);

      return Response.ok(jsonEncode({}));
    } catch (e, s) {
      log.error('Erro ao notificar', e, s);
      return Response.internalServerError(
        body: jsonEncode({'message': 'erro ao enviar notificação'}),
      );
    }
  }

  @Route.get('/user')
  Future<Response> findChatsByUser(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final chats = await service.getChatByUser(user);
      final resultChats = chats
          .map((e) => {
                'id': e.id,
                'user': e.user,
                'name': e.name,
                'pet_name': e.petName,
                'supplier': {
                  'id': e.supplier.id,
                  'name': e.supplier.name,
                  'logo': e.supplier.logo
                }
              })
          .toList();

      return Response.ok(jsonEncode(resultChats));
    } catch (e, s) {
      log.error('Erro ao listar chats em aberto para o usuario', e, s);
      return Response.internalServerError();
    }
  }

  @Route.get('/supplier')
  Future<Response> findChatsBySupplier(Request request) async {
    final supplier = request.headers['supplier'];
    if(supplier == null){
      return Response.badRequest(body: jsonEncode({'message': 'usuario logado nao é um fornecedor'}));
    }

    final supplierId = int.parse(supplier);
    final chats = await service.getChatBySupplier(supplierId);

    final resultChats = chats
          .map((e) => {
                'id': e.id,
                'user': e.user,
                'name': e.name,
                'pet_name': e.petName,
                'supplier': {
                  'id': e.supplier.id,
                  'name': e.supplier.name,
                  'logo': e.supplier.logo
                }
              })
          .toList();

      return Response.ok(jsonEncode(resultChats));

  }

  Router get router => _$ChatControllerRouter(this);
}
