// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:cuidapet_api/modules/categories/service/i_categories_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'categories_controller.g.dart';

@injectable
class CategoriesController {
  ICategoriesService service;
  CategoriesController({
    required this.service,
  });

  @Route.get('/')
  Future<Response> findAll(Request request) async {
    try {
      final categories = await service.findAll();
      final categoriesResponse = categories
          .map((e) => {"id": e.id, "name": e.name, "type": e.type})
          .toList();

      return Response.ok(jsonEncode(categoriesResponse));
    } catch (e) {
      return Response.internalServerError();
    }
  }

  Router get router => _$CategoriesControllerRouter(this);
}
