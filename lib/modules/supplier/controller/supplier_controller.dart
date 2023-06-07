// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/modules/supplier/service/i_supplier_service.dart';
import 'package:cuidapet_api/modules/supplier/view_models/create_supplier_user_view_model.dart';
import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'supplier_controller.g.dart';

@Injectable()
class SupplierController {
  final ISupplierService service;
  final ILogger log;
  SupplierController({
    required this.service,
    required this.log,
  });

  @Route.get('/')
  Future<Response> findNearByMe(Request request) async {
    try {
      final lat = double.tryParse(request.url.queryParameters['lat'] ?? '');
      final long = double.tryParse(request.url.queryParameters['lng'] ?? '');

      if (lat == null || long == null) {
        return Response(
          400,
          body: jsonEncode({'message': 'Latitude e longitude obrigatórios'}),
        );
      }

      final suppliers = await service.findNearByMe(lat, long);
      final result = suppliers
          .map((e) => {
                'id': e.id,
                'name': e.name,
                'logo': e.logo,
                'distance': e.distance,
                'catetogy': e.categoryId
              })
          .toList();

      return Response.ok(jsonEncode(result));
    } catch (e, s) {
      log.error('Erro ao buscar fornecedores nas proximidades', e, s);
      return Response.internalServerError(
          body: jsonEncode(
              {"message": 'Erro ao buscar fornecedores nas proximidades, $e'}));
    }
  }

  @Route.get('/<id|[0-9]+>')
  Future<Response> findById(Request request, String id) async {
    final supplier = await service.findById(int.parse(id));

    if (supplier == null) {
      return Response.ok(jsonEncode({}));
    }

    return Response.ok(_supplierMapper(supplier));
  }

  @Route.get('/<supplierId|[0-9]+>/services')
  Future<Response> findServicesBySupplierId(
      Request request, String supplierId) async {
    try {
      final supplierServices =
          await service.findServiceBySupplier(int.parse(supplierId));
      final result = supplierServices
          .map((e) => {
                'id': e.id,
                'supplier_id': e.supplierId,
                'name': e.name,
                'price': e.price
              })
          .toList();

      return Response.ok(jsonEncode(result));
    } catch (e, s) {
      log.error('Erro ao buscar serviços', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro do buscar serviço'}));
    }
  }

  @Route.get('/user')
  Future<Response> checkUserExistis(Request request) async {
    final email = request.url.queryParameters['email'];
    if (email == null) {
      return Response(400, body: jsonEncode({'message': 'E-mail obrigatorio'}));
    }
    final isEmailExists = await service.checkUserExistis(email);
    return isEmailExists ? Response(200) : Response(204);
  }

  @Route.post('/user')
  Future<Response> createNewUser(Request request) async {
    try {
      final model = CreateSupplierUserViewModel(
          dataRequest: await request.readAsString());

      await service.createUserSupplier(model);

      return Response.ok(
          jsonEncode({"message": "supplier user cadastrado com sucesso!"}));
    } catch (e, s) {
      log.error('Erro ao cadastrar novo fornecedor', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao cadastrar novo fornecedor'}));
    }
  }

  @Route.put('/')
  Future<Response> update(Request request) async {
    try {
  final supplier = int.parse(request.headers['supplier']!);
  
  final model = SupplierUpdateInputModel(
      dataRequest: await request.readAsString(), supplierId: supplier);
  
    final supplierResponse = await service.update(model);
  
  return Response.ok(_supplierMapper(supplierResponse));
} catch (e, s) {
  log.error('Erro ao atualizar fornecedor', e, s);
  return Response.internalServerError();

}
  }

  String _supplierMapper(Supplier supplier) {
    return jsonEncode({
      'id': supplier.id,
      'name': supplier.name,
      'logo': supplier.logo,
      'address': supplier.address,
      'phone': supplier.phone,
      'lat': supplier.lat,
      'long': supplier.long,
      'category': {
        'id': supplier.category?.id,
        'name': supplier.category?.name,
        'type': supplier.category?.type,
      }
    });
  }

  Router get router => _$SupplierControllerRouter(this);
}
