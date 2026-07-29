/// App-wide configuration constants.
class AppConfig {
  AppConfig._();

  /// Google Maps API key. Leave empty to fall back to the free OpenStreetMap
  /// tiles (no key / no billing required). When a valid key is provided the
  /// location picker renders a native Google map instead.
  ///
  /// If you set this, also add the key to the Android manifest
  /// (`com.google.android.geo.API_KEY` meta-data) and the iOS AppDelegate
  /// (`GMSServices.provideAPIKey`) — see docs/API.md.
  static const String googleMapsApiKey = '';

  static bool get hasGoogleMaps => googleMapsApiKey.trim().isNotEmpty;
}
