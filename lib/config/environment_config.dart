enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static const String _devBaseUrl =
      'https://openlabel-555118069489.us-central1.run.app/process-image';
  static const String _stagingBaseUrl =
      'https://openlabel-555118069489.us-central1.run.app/process-image';
  static const String _prodBaseUrl =
      'https://openlabel-555118069489.us-central1.run.app/process-image';

  static const String _devUsersCollection = 'users_development';
  static const String _stagingUsersCollection = 'users_staging';
  static const String _prodUsersCollection = 'users_production';

  static const String _devProductsCollection = 'products_development';
  static const String _stagingProductsCollection = 'products_staging';
  static const String _prodProductsCollection = 'products_production';

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return _devBaseUrl;
      case Environment.staging:
        return _stagingBaseUrl;
      case Environment.production:
        return _prodBaseUrl;
    }
  }

  static String get usersCollection {
    switch (_environment) {
      case Environment.development:
        return _devUsersCollection;
      case Environment.staging:
        return _stagingUsersCollection;
      case Environment.production:
        return _prodUsersCollection;
    }
  }

  static String get productsCollection {
    switch (_environment) {
      case Environment.development:
        return _devProductsCollection;
      case Environment.staging:
        return _stagingProductsCollection;
      case Environment.production:
        return _prodProductsCollection;
    }
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
}
