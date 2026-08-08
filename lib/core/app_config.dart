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

  /// SPKI pins for all API domains we call.
  /// nextgenscholars.click (Let's Encrypt): leaf, YE2 intermediate, Root YE.
  /// render.com (Google Trust, kept as backup): leaf, WE1, GTS Root R4.
  static const List<String> pinnedCertHashes = [
    'v7HrufZF+O/OjynmX+P8k9NhlGgDBlgyzSe54yUxDtU=',
    's/tdAOmUzd8syaTuqfgGvFcn6DzA5Cmb+Vby1ST+U3Y=',
    'sCkq5UWXjg+7mKu9lMhhYF5bGLsy7VI/UNW3tccdR7w=',
    'fizfE9JVlzlRplEx7epXfqW9enrbLvwF/LU26XTPEG4=',
    'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=',
    'mEflZT5enoR1FuXLgYYGqnVEoZvmf9c2bVBpiOjYQ0c=',
  ];
}
