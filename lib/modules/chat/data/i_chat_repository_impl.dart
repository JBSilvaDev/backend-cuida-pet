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
          userId: resultMySql['user_id'],
          supplier: Supplier(
            id: resultMySql['fornec_id'],
            name: resultMySql['fornec_nome'],
          ),

          name: resultMySql['agendamento_nome'],
          petName: resultMySql['nome_pet'],
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
}
