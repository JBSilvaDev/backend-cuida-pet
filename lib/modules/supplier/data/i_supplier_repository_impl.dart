// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/database/i_database_connection.dart';
import 'package:cuidapet_api/app/exceptions/database_exception.dart';
import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/dtos/supplier_near_by_mr_dto.dart';
import 'package:cuidapet_api/entities/category.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './i_supplier_repository.dart';

@LazySingleton(as: ISupplierRepository)
class ISupplierRepositoryImpl implements ISupplierRepository {
  final IDatabaseConnection connection;
  final ILogger log;
  ISupplierRepositoryImpl({
    required this.connection,
    required this.log,
  });

  @override
  Future<List<SupplierNearByMrDto>> findNearByPosition(
      double lat, double long, int distance) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();
      final query = '''
      select f.id, f.nome, f.logo, f.categorias_fornecedor_id,
        (6371 *
          acos(
            cos(radians($lat)) * 
            cos(radians(ST_X(f.latlng))) *
            cos(radians($long) - radians(ST_Y(f.latlng))) + 
            sin(radians($lat)) * 
            sin(radians(ST_X(f.latlng)))
          )) As distancia
        from fornecedor f
        having distancia <=$distance
        Order by distancia
      ''';

      final result = await conn.query(query);

      return result
          .map((e) => SupplierNearByMrDto(
                id: e['id'],
                name: e['nome'] ?? '',
                distance: e['distancia'] ?? 0,
                categoryId: e['categorias_fornecedor_id'] ?? '',
                logo: (e['logo'] as Blob?).toString(),
              ))
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar fornecedores pela posição', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<Supplier?> findById(int id) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final query = '''
          SELECT
            f.id, f.nome, f.logo, f.endereco, f.telefone, 
            ST_X(f.latlng) AS lat,
            ST_Y(f.latlng) AS lng,
            f.categorias_fornecedor_id, c.nome_categoria, c.tipo_categoria
        FROM fornecedor AS f
        INNER JOIN categorias_fornecedor AS c ON (f.categorias_fornecedor_id = c.id)
        where
          f.id = ?
        ''';
      final result = await conn.query(query, [id]);
      if (result.isNotEmpty) {
        final dataMyql = result.first;
        return Supplier(
            id: dataMyql['id'],
            name: dataMyql['nome'],
            logo: (dataMyql['logo'] as Blob?).toString(),
            address: dataMyql['endereco'],
            phone: dataMyql['telefone'],
            lat: dataMyql['lat'],
            long: dataMyql['lng'],
            category: Category(
              id: dataMyql['categorias_fornecedor_id'],
              name: dataMyql['nome_categoria'],
              type: dataMyql['tipo_categoria'],
            ));
      }
      return null;
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar fornecedor', e, s);
      throw DatabaseException(
        exception: e,
      );
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<SupplierService>> findServicesBySupplierId(int supplierId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
      select id, fornecedor_id, nome_servico, valor_servico
      from fornecedor_servicos
      where fornecedor_id = ?
      ''', [supplierId]);

      if (result.isEmpty) {
        return [];
      }
      return result
          .map((e) => SupplierService(
                id: e['id'],
                supplierId: e['fornecedor_id'],
                name: e['nome_servico'],
                price: e['valor_servico'],
              ))
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar os serviços de fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<bool> checkUserExistis(String email) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn
          .query('select count(*) from usuario where email = ?', [email]);
      final dataMysql = result.first;

      return dataMysql[0] > 0;
    } on MySqlException catch (e, s) {
      log.error('Erro ao verificar e-mail existente', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<int> saveSuppliert(Supplier supplier) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
      insert into fornecedor(nome, logo, endereco, telefone, latlng, categorias_fornecedor_id)
      values(?,?,?,?,ST_GeomfromText(?),?)
      ''', [
        supplier.name,
        supplier.logo,
        supplier.address,
        supplier.phone,
        'POINT(${supplier.lat ?? 0} ${supplier.long ?? 0})',
        supplier.category?.id
      ]);

      return result.insertId ?? 0;
    } on MySqlException catch (e, s) {
      log.error('Erro ao salvar fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<Supplier> update(Supplier supplier) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();
      await conn.query('''
      update fornecedor
        set
          nome = ?,
          logo = ?,
          telefone = ?,
          latlng = ST_GeomFromText(?),
          categorias_fornecedor_id = ?
        where
          id = ?
      ''', [
        supplier.name,
        supplier.logo,
        supplier.phone,
        'POINT(${supplier.lat} ${supplier.long})',
        supplier.category?.id,
        supplier.id
      ]);

      Category? category;
      if (supplier.category?.id != null) {
        final resultCategory = await conn.query(
            'select * from categorias_fornecedor where id = ?',
            [supplier.category?.id]);
        var categoryData = resultCategory.first;
        category = Category(
          id: categoryData['id'],
          name: categoryData['nome_categoria'],
          type: categoryData['tipo_categoria'],
        );
      }

      return supplier.copyWith(category: category);
    } on MySqlException catch (e, s) {
      log.error('Erro ao atualizar dados do fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}
