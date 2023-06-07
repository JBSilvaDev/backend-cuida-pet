// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import 'package:cuidapet_api/app/config/database_connection_config.dart';

import './i_database_connection.dart';

@LazySingleton(as: IDatabaseConnection)
class IDatabaseConnectionImpl implements IDatabaseConnection {
  final DatabaseConnectionConfig _config;

  IDatabaseConnectionImpl(this._config);

  @override
  Future<MySqlConnection> openConnection() async {
    
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: _config.host,
        port: _config.port,
        db: _config.dbName,
        password: _config.password,
        user: _config.user));

        await Future.delayed(Duration(milliseconds: 500));

    return conn;
  }
}
