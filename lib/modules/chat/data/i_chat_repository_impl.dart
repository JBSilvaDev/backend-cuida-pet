// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/exceptions/database_exception.dart';
import 'package:cuidapet_api/entities/chat.dart';
import 'package:cuidapet_api/entities/device_token.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import '../../../app/database/i_database_connection.dart';
import '../../../app/logger/i_logger.dart';
import './i_chat_repository.dart';

@LazySingleton(as: IChatRepository)
class IChatRepositoryImpl implements IChatRepository {
  final IDatabaseConnection connection;
  final ILogger log;
  IChatRepositoryImpl({
    required this.connection,
    required this.log,
  });
  @override
  Future<int> startChat(int scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
      insert into chats (agendamento_id, status, data_criacao) values(?,?,?)
      ''', [
        scheduleId,
        'A',
        DateTime.now().toIso8601String(),
      ]);
      return result.insertId!;
    } on MySqlException catch (e, s) {
      log.error('Erro ao iniciar chat', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<Chat?> findChatById(int chatId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final query = '''
        select 
          c.id,
          c.data_criacao,
          c.status,
          a.nome as agendamento_nome,
          a.nome_pet as agendamento_nome_pet,
          a.usuario_id,
          a.fornecedor_id,
          f.nome as fornec_nome,
          f.logo,
          u.android_token as user_android_token,
          u.ios_token as user_ios_token,
          uf.ios_token as fornec_ios_token,
          uf.android_token as fornec_android_token
        from chats as c
        inner join agendamento a on a.id = c.agendamento_id
        inner join fornecedor f on f.id = a.fornecedor_id
        inner join usuario u on u.id = a.usuario_id
        inner join usuario uf on uf.fornecedor_id = f.id
        where c.id = ?
      ''';
      final result = await conn.query(query, [chatId]);

      if (result.isNotEmpty) {
        final resultMySql = result.first;
        return Chat(
          id: resultMySql['id'],
          user: resultMySql['usuario_id'],
          supplier: Supplier(
            id: resultMySql['fornecedor_id'],
            name: resultMySql['fornec_nome'],
          ),
          name: resultMySql['agendamento_nome'],
          petName: resultMySql['agendamento_nome_pet'],
          status: resultMySql['status'],
          userDeviceToken: DeviceToken(
            android: (resultMySql['user_android_token'] as Blob?)?.toString(),
            ios: (resultMySql['user_ios_token'] as Blob?)?.toString(),
          ),
          supplierDeviceToken: DeviceToken(
            android: (resultMySql['fornec_android_token'] as Blob?)?.toString(),
            ios: (resultMySql['fornec_ios_token'] as Blob?)?.toString(),
          ),
        );
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao localizar chat', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Chat>> getChatsByUser(int user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final query = '''
      select
          c.id, c.data_criacao, c.status,
          a.nome, a.nome_pet, a.fornecedor_id, a.usuario_id,
          f.nome as fornec_nome, f.logo
        from chats as c
        inner join agendamento a on a.id = c.agendamento_id
        inner join fornecedor f on f.id = a.fornecedor_id
        where
          a.usuario_id = ?
        and
          c.status = 'A'
        order by c.data_criacao
      ''';
      final result = await conn.query(query, [user]);
      return result
          .map(
            (e) => Chat(
              id: e['id'],
              user: e['usuario_id'],
              supplier: Supplier(
                id: e['fornecedor_id'],
                name: e['fornec_nome'],
                logo: (e['logo'] as Blob?)?.toString(),
              ),
              name: e['nome'],
              petName: e['nome_pet'],
              status: e['status'],
            ),
          )
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Erro ao localizar chat do usuario', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Chat>> getChatsBySupplier(int supplier) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final query = '''
      select
          c.id, c.data_criacao, c.status,
          a.nome, a.nome_pet, a.fornecedor_id, a.usuario_id,
          f.nome as fornec_nome, f.logo
        from chats as c
        inner join agendamento a on a.id = c.agendamento_id
        inner join fornecedor f on f.id = a.fornecedor_id
        where
          a.fornecedor_id = ?
        and
          c.status = 'A'
        order by c.data_criacao
      ''';
      final result = await conn.query(query, [supplier]);
      return result
          .map(
            (e) => Chat(
              id: e['id'],
              user: e['usuario_id'],
              supplier: Supplier(
                id: e['fornecedor_id'],
                name: e['fornec_nome'],
                logo: (e['logo'] as Blob?)?.toString(),
              ),
              name: e['nome'],
              petName: e['nome_pet'],
              status: e['status'],
            ),
          )
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Erro ao localizar chat do fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> endChat(int chatId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      await conn.query('''
      update chats set status = 'F' where id = ?
      ''', [chatId]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao finalizar chat', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}
