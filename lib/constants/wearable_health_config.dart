/// Open Wearables / Samsung Health SDK configuration.
///
/// Fill in [host] and either [apiKey] or token credentials from your backend.
/// Preferred production flow: your backend creates Open Wearables tokens and
/// the app signs in with accessToken + refreshToken (see [WearableHealthService]).
class WearableHealthConfig {
  /// Open Wearables API base URL (no `/api/v1` path).
  static const String host = 'https://api.openwearables.io';

  /// Optional API-key auth for internal / staging builds only.
  /// Leave empty in production and use token sign-in instead.
  static const String apiKey = '';

  /// Days of history to sync on first / background sync.
  static const int syncDaysBack = 90;

  static bool get isHostConfigured => host.trim().isNotEmpty;

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}
