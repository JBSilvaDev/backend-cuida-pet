// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:http/http.dart' as http;

class PushNotificationFacede {
  final ILogger log;
  PushNotificationFacede({
    required this.log,
  });

  Future<void> sendMessage({
    required List<String?> devices,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    final request = {
      'notification': {
        'body': body,
        'title': title,
      },
      'priority': 'high',
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done',
        'payload': payload
      },
    };

    for (var device in devices) {
      if (device != null) {
        request['to'] = device;
        log.info('Enviando menssagem para $device');
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'), body: jsonEncode(request), headers: {'Autorization':'', 'Content-Type':'application/json'},);

      }
    }
  }
}
