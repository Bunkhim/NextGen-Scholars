class AppConfig {
  AppConfig._();

  static String get backendApiUrl =>
      const String.fromEnvironment(
        'BACKEND_API_URL',
        defaultValue: 'https://nextgen-api-cf38.onrender.com',
      );

  static String get googleWebClientId =>
      const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: '1043004620020-f5cuppbqdlqbfvah6cl4nq7fg709sv6i.apps.googleusercontent.com',
      );

  static const String pinnedCertHash =
      'fizfE9JVlzlRplEx7epXfqW9enrbLvwF/LU26XTPEG4=';
}
