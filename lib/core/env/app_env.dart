class AppEnv {
  const AppEnv._();

  static const appName = 'Noccaro';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mock.local',
  );

  // During MVP prototyping this app runs against local mock repositories.
  static const useMockBackend = true;

  // Keep map fallback enabled while API keys are not configured.
  static const enableNativeMapWidget = false;
}
