import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { mock, local, production }

class EnvConfig {
  static Environment get currentEnv {
    final envStr = dotenv.env['APP_ENV'] ?? 'mock';
    switch (envStr.toLowerCase()) {
      case 'production':
        return Environment.production;
      case 'local':
        return Environment.local;
      case 'mock':
      default:
        return Environment.mock;
    }
  }

  static bool get isMock => currentEnv == Environment.mock;

  static String get apiBaseUrl {
    if (currentEnv == Environment.production) {
      return dotenv.env['API_BASE_URL_PROD'] ?? '';
    }
    return dotenv.env['API_BASE_URL_LOCAL'] ?? 'http://10.0.2.2:8000/api/v1';
  }

  static String get wsBaseUrl {
    if (currentEnv == Environment.production) {
      return dotenv.env['WS_BASE_URL_PROD'] ?? '';
    }
    return dotenv.env['WS_BASE_URL_LOCAL'] ?? 'ws://10.0.2.2:8000/ws';
  }
}
