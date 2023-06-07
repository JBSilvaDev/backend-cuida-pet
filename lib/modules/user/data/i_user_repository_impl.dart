// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cuidapet_api/app/database/i_database_connection.dart';
import 'package:cuidapet_api/app/exceptions/database_exception.dart';
import 'package:cuidapet_api/app/exceptions/user_exeptions.dart';
import 'package:cuidapet_api/app/helpers/cripty_utils_helper.dart';
import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/view_models/platform_enum.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './i_user_repository.dart';

@LazySingleton(as: IUserRepository)
class IUserRepositoryImpl implements IUserRepository {
  final IDatabaseConnection connection;
  final ILogger log;

  IUserRepositoryImpl({
    required this.connection,
    required this.log,
  });
  @override
  Future<User> createUser(User user) async {
    MySqlConnection? conn;

    try {
      if (user.password == '' || user.password == null) {
        log.error(
            'Senha invalida, não pode ser vazia ou menor que 6 caracteres');
        throw Exception();
      }
      conn = await connection.openConnection();

      final query = '''
        insert into usuario(email, tipo_cadastro, img_avatar, senha, fornecedor_id, social_id)
        values(?,?,?,?,?,?)
        ''';
      final result = await conn.query(query, [
        user.email,
        user.registerType,
        user.imageAvatar,
        CriptyUtilsHelper.generateSha256Gash(user.password ?? ''),
        user.supplierId,
        user.socialKey
      ]);

      final userId = result.insertId;

      return user.copyWith(id: userId, password: null);
    } on MySqlException catch (e, s) {
      if (e.message.contains('usuario.email_UNIQUE')) {
        log.error('Usuario ja cadastrado', e, s);
        throw UserExistsException();
      }
      log.error('Erro ao criar usuario', e, s);
      throw DatabaseException(message: 'Erro no banco de dados', exception: e);
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> loginWithEmailPassword(
      String email, String password, bool supplierUser) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();
      var query = '''
      select * 
      from usuario where email = ? and senha = ?''';
      if (supplierUser == true) {
        query += ' and fornecedor_id is not null';
      } else {
        query += ' and fornecedor_id is null';
      }
      final result = await conn.query(query, [
        email,
        CriptyUtilsHelper.generateSha256Gash(password),
      ]);
      if (result.isEmpty) {
        log.error('Usuario ou senha invalidos!');
        throw UserNotFoundException(message: 'Usuario ou senha invalidos');
      } else {
        final userSqlData = result.first;
        return User(
          id: userSqlData['id'] as int,
          email: userSqlData['email'],
          registerType: userSqlData['tipo_cadastro'],
          iosToken: (userSqlData['ios_token'] as Blob?)?.toString(),
          androidToken: (userSqlData['android_token'] as Blob?)?.toString(),
          refreshToken: (userSqlData['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (userSqlData['img_avatar'] as Blob?)?.toString(),
          supplierId: userSqlData['fornecedor_id'],
        );
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao realizar login', e, s);
      throw DatabaseException(message: e.message);
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> loginBySocialKey(
      String email, String socialKey, String socialType) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final result =
          await conn.query('select * from usuario where email = ?', [email]);

      if (result.isEmpty) {
        throw UserNotFoundException(message: 'Usuario não encontrado');
      } else {
        final dataMysql = result.first;
        if (dataMysql['social_id'] == null ||
            dataMysql['social_key'] != socialKey) {
          await conn.query('''update usuario set social_id = ?, 
            tipo_cadastro = ? where id = ?''',
              [socialKey, socialType, dataMysql['id']]);
        }

        return User(
          id: dataMysql['id'] as int,
          email: dataMysql['email'],
          registerType: dataMysql['tipo_cadastro'],
          iosToken: (dataMysql['ios_token'] as Blob?)?.toString(),
          androidToken: (dataMysql['android_token'] as Blob?)?.toString(),
          refreshToken: (dataMysql['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (dataMysql['img_avatar'] as Blob?)?.toString(),
          supplierId: dataMysql['fornecedor_id'],
        );
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao fazer login social', e, s);
      throw DatabaseException(
          message: 'Erro ao tentar fazer login social', exception: e);
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateUserAndRefreshToken(User user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final setParams = {};

      if (user.iosToken != '') {
        setParams.putIfAbsent('ios_token', () => user.iosToken);
      } else {
        setParams.putIfAbsent('android_token', () => user.androidToken);
      }

      final query = """
        update usuario
        set ${setParams.keys.elementAt(0)} = ?,
        refresh_token = ? 
        where id = ?
        """;

      await conn.query(query, [
        setParams.values.elementAt(0),
        user.refreshToken!,
        user.id!,
      ]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao confirmar login', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateRefreshToken(User user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      await conn.query('update usuario set refresh_token = ? where id = ?',
          [user.refreshToken!, user.id]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao atualizar token', e, s);
      throw DatabaseException(message: 'Erro ao atualizar token');
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> findById(int id) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
        select id, email, tipo_cadastro, ios_token, android_token, refresh_token, img_avatar, fornecedor_id
        from usuario where id = ?
        ''', [id]);

      if (result.isEmpty) {
        log.error('Usuario nao encontrado com o id: $id');
        throw UserNotFoundException(
            message: 'Usuario nao encontrado com o id: $id');
      } else {
        final dataMysql = result.first;
        return User(
          id: dataMysql['id'] as int,
          email: dataMysql['email'],
          registerType: dataMysql['tipo_cadastro'],
          iosToken: (dataMysql['ios_token'] as Blob?)?.toString(),
          androidToken: (dataMysql['android_token'] as Blob?)?.toString(),
          refreshToken: (dataMysql['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (dataMysql['img_avatar'] as Blob?)?.toString(),
          supplierId: dataMysql['fornecedor_id'],
        );
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar usuario por id', e, s);
      throw DatabaseException(message: 'Erro ao buscar usuario por id');
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateUrlAvatar(int id, String urlAvatar) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();
      await conn.query('''
        update usuario set img_avatar = ? where id = ?
        ''', [urlAvatar, id]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao atualizar o avatar', e, s);
      throw DatabaseException(message: 'Erro ao atualizar avatar');
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateDeviceToken(
      int id, String token, PlatformEnum platform) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();
      var set = '';
      if (platform == PlatformEnum.ios) {
        set = 'ios_token = ?';
      } else {
        set = 'android_token = ?';
      }
      final query = 'update usuario set $set where id = ?';
      await conn.query(query, [token, id]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao atualizar o tipo de dispositivo', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}
