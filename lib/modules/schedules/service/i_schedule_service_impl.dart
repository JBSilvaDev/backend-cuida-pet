// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:injectable/injectable.dart';

import 'package:cuidapet_api/entities/schedule.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
import 'package:cuidapet_api/modules/schedules/data/i_schedule_repository.dart';
import 'package:cuidapet_api/modules/schedules/view_models/schedule_save_input.dart';

import '../../../entities/schedule_supplier_service.dart';
import './i_schedule_service.dart';

@LazySingleton(as: IScheduleService)
class IScheduleServiceImpl implements IScheduleService {
  IScheduleRepository repository;
  IScheduleServiceImpl({
    required this.repository,
  });
  @override
  Future<void> scheduleServices(ScheduleSaveInput model) async {
    final schedule = Schedule(
        userId: model.userId,
        status: 'P',
        scheduleDate: model.scheduleDate,
        name: model.name,
        petName: model.petName,
        supplier: Supplier(id: model.supplierId),
        services: model.services
            .map((e) => ScheduleSupplierService(
                  service: SupplierService(id: e),
                ))
            .toList());

    await repository.save(schedule);
  }

  @override
  Future<void> changeStatus(String status, int scheduleId) =>
      repository.changeStatus(status, scheduleId);
      
        @override
        Future<List<Schedule>> findAllScheduleByUser(int userId) => repository.findAllSchedulesByUser(userId);
        
}
