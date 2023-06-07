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
    final model = ChatNotifyViewModel(await request.readAsString());
    
    return Response.ok(jsonEncode(''));
  }

  Router get router => _$ChatControllerRouter(this);
}
