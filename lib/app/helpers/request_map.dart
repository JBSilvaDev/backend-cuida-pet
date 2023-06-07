// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

abstract class RequestMap {
  final Map<String, dynamic> data;
  RequestMap.empty() : data = {};

  RequestMap(String dataRequest) : data = jsonDecode(dataRequest) {
    map();
  }
  void map();
}
