import 'package:cuidapet_api/entities/schedule.dart';
import 'package:cuidapet_api/modules/schedules/view_models/schedule_save_input.dart';

abstract class IScheduleService {
  Future<void> scheduleServices(ScheduleSaveInput model);
  Future<void> changeStatus(String status, int scheduleId);
  Future<List<Schedule>> findAllScheduleByUser(int userId);

}
