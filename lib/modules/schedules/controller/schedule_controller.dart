// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/modules/schedules/service/i_schedule_service.dart';
import 'package:cuidapet_api/modules/schedules/view_models/schedule_save_input.dart';

part 'schedule_controller.g.dart';

@Injectable()
class ScheduleController {
  final IScheduleService service;
  final ILogger log;
  ScheduleController({
    required this.service,
    required this.log,
  });
  @Route.post('/')
  Future<Response> scheduleServices(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);
      final inputModel = ScheduleSaveInput(
          userId: userId, dataRequest: await request.readAsString());
      await service.scheduleServices(inputModel);
      return Response.ok(jsonEncode({}));
    } catch (e, s) {
      log.error('Erro ao salvar agendamento', e, s);
      return Response.internalServerError();
    }
  }

  @Route.put('/<scheduleId|[0-9]+>/status/<status>')
  Future<Response> changeStatus(
      Request request, String scheduleId, String status) async {
    try {
      await service.changeStatus(status, int.parse(scheduleId));
      return Response.ok(
          jsonEncode({"message": "status alterado com sucesso"}));
    } catch (e, s) {
      log.error('Erro ao alterar status do servico', e, s);
      return Response.internalServerError();
    }
  }

  @Route.get('/')
  Future<Response> findAllSchedulesByUser(Request request) async {
    try {
  final userId = int.parse(request.headers['user']!);
  final result = await service.findAllScheduleByUser(userId);
  final response = result
      .map((e) => {
            'id': e.id,
            'schedule_date': e.scheduleDate.toIso8601String(),
            'status': e.status,
            'name': e.name,
            'pet_name': e.petName,
            'supplier': {
              'id': e.supplier.id,
              'name': e.supplier.name,
              'logo': e.supplier.logo
            },
            'services': e.services
                .map((e) => {
                      'id': e.service.id,
                      'name': e.service.name,
                      'price': e.service.price
                    })
                .toList()
          })
      .toList();
  
  return Response.ok(jsonEncode(response));
}  catch (e, s) {
  log.error('Erro ao buscar agendamentos do usuario ', e, s);
  return Response.internalServerError();

}
  }

  Router get router => _$ScheduleControllerRouter(this);
}
