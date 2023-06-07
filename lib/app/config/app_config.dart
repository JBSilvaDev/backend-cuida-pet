import 'package:cuidapet_api/app/config/database_connection_config.dart';
import 'package:cuidapet_api/app/config/service_locator.dart';
import 'package:cuidapet_api/app/logger/i_logger.dart';
import 'package:cuidapet_api/app/logger/i_logger_impl.dart';
import 'package:dotenv/dotenv.dart' show load, env;
import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';
import '../routers/i_router_config.dart';

class AppConfig {
  Future<void>loadConfigApplication(Router router) async {
    await _loadEnv();
    _loadDatabaseConfig();
    _configLogger();
    _loadDependecies();
    _loadRouterConfig(router);
  }

  Future<void> _loadEnv() async => load();

  void _loadDatabaseConfig() {
    final databaseConfig = DatabaseConnectionConfig(
        host: env['DATABASE_HOST'] ?? env['databaseHost']!,
        user: env['DATABASE_USER'] ?? env['databaseUser']!,
        password: env['DATABASE_PASSWORD'] ?? env['databasePassword']!,
        port: int.tryParse(env['DATABASE_PORT'] ?? env['databasePort']!) ?? 0,
        dbName: env['DATABASE_NAME'] ?? env['databaseName']!);

    GetIt.I.registerSingleton(databaseConfig);
  }

  void _configLogger() =>
      GetIt.I.registerLazySingleton<ILogger>(() => ILoggerImpl());

  void _loadDependecies() => configureDependencies();

  void _loadRouterConfig(Router router) => IRouterConfig(router).configure();
}
