class SnapITConfig {
  static const String _envApiKey = String.fromEnvironment(
    'SNAPIT_SDK_API_KEY',
    defaultValue: '',
  );

  static const String _envUserId = String.fromEnvironment(
    'SNAPIT_USER_ID',
    defaultValue: '',
  );

  /// Runtime overridden API key (e.g. from local storage)
  static String runtimeApiKey = '';

  /// Runtime overridden User ID (e.g. from local storage)
  static String runtimeUserId = '';

  /// Runtime overridden Model Name (e.g. from local storage)
  static String runtimeModelName = '';

  /// Runtime overridden Version (e.g. from local storage)
  static double? runtimeVersion;

  /// Returns the overridden API Key if set, otherwise falls back to compile-time env value.
  static String get apiKey => runtimeApiKey.isNotEmpty ? runtimeApiKey : _envApiKey;

  /// Returns the overridden User ID if set, otherwise falls back to compile-time env value.
  static String get userId => runtimeUserId.isNotEmpty ? runtimeUserId : _envUserId;

  /// Returns the overridden Model Name if set, otherwise defaults to 'fast'.
  static String get modelName => runtimeModelName.isNotEmpty ? runtimeModelName : 'fast';

  /// Returns the overridden Version if set, otherwise defaults to 1.1.
  static double get version => runtimeVersion ?? 1.1;

  /// Utility to check if both keys are configured (either in env or local storage).
  static bool get isConfigured => apiKey.isNotEmpty && userId.isNotEmpty;
}
