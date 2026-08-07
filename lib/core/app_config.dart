class AppConfig {
  AppConfig._();

  static String get backendApiUrl =>
      const String.fromEnvironment(
        'BACKEND_API_URL',
        defaultValue: 'https://api.nextgenscholars.click',
      );

  static String get googleWebClientId =>
      const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: '1043004620020-f5cuppbqdlqbfvah6cl4nq7fg709sv6i.apps.googleusercontent.com',
      );

  static const List<String> pinnedCertHashes = [
    'v7HrufZF+O/OjynmX+P8k9NhlGgDBlgyzSe54yUxDtU=',
    's/tdAOmUzd8syaTuqfgGvFcn6DzA5Cmb+Vby1ST+U3Y=',
    'sCkq5UWXjg+7mKu9lMhhYF5bGLsy7VI/UNW3tccdR7w=',
    'BB7Exp9mdxl7TvHAZ0IRZPSyadon8vUwKSyruwUfwbE=',
  ];
}
