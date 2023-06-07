// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/helpers/request_map.dart';

class ScheduleSaveInput extends RequestMap {
  int userId;
  late DateTime scheduleDate;
  late String name;
  late String petName;
  late int supplierId;
  late List<int> services;
  ScheduleSaveInput({required this.userId, required String dataRequest})
      : super(dataRequest);

  @override
  void map() {
    scheduleDate = DateTime.parse(data['schedule_data']);
    supplierId = data['supplier_id'];
    services = List.castFrom<dynamic, int>(data['services']);
    name = data['name'];
    petName = data['pet_name'];
  }
}
