import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A helper class to manage all app preferences using SharedPreferences
class PreferencesHelper {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyOfflineMode = 'offline_mode';
  static const String _keyDownloadedRegions = 'downloaded_regions';
  static const String _keyLanguage = 'app_language';
  static const String _keyCurrency = 'app_currency';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyLocationServices = 'location_services_enabled';
  static const String _keyLastSync = 'last_sync_timestamp';

  final SharedPreferences _prefs;

  PreferencesHelper(this._prefs);

  // Auth token management
  String? getAuthToken() => _prefs.getString(_keyToken);

  Future<bool> setAuthToken(String token) => _prefs.setString(_keyToken, token);

  Future<bool> removeAuthToken() => _prefs.remove(_keyToken);

  // User data management
  Map<String, dynamic>? getUserData() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;

    try {
      return json.decode(userJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  Future<bool> setUserData(Map<String, dynamic> userData) =>
      _prefs.setString(_keyUser, json.encode(userData));

  Future<bool> removeUserData() => _prefs.remove(_keyUser);

  // Offline mode management
  bool isOfflineMode() => _prefs.getBool(_keyOfflineMode) ?? false;

  Future<bool> setOfflineMode(bool enabled) =>
      _prefs.setBool(_keyOfflineMode, enabled);

  // Downloaded regions management
  List<String> getDownloadedRegions() =>
      _prefs.getStringList(_keyDownloadedRegions) ?? [];

  Future<bool> setDownloadedRegions(List<String> regions) =>
      _prefs.setStringList(_keyDownloadedRegions, regions);

  Future<bool> addDownloadedRegion(String region) {
    final regions = getDownloadedRegions();
    if (!regions.contains(region)) {
      regions.add(region);
      return setDownloadedRegions(regions);
    }
    return Future.value(true);
  }

  Future<bool> removeDownloadedRegion(String region) {
    final regions = getDownloadedRegions();
    if (regions.contains(region)) {
      regions.remove(region);
      return setDownloadedRegions(regions);
    }
    return Future.value(true);
  }

  // App language management
  String getAppLanguage() => _prefs.getString(_keyLanguage) ?? 'en';

  Future<bool> setAppLanguage(String languageCode) =>
      _prefs.setString(_keyLanguage, languageCode);

  // Currency format management
  String getAppCurrency() => _prefs.getString(_keyCurrency) ?? 'USD';

  Future<bool> setAppCurrency(String currencyCode) =>
      _prefs.setString(_keyCurrency, currencyCode);

  // Theme mode management
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';

  Future<bool> setThemeMode(String themeMode) =>
      _prefs.setString(_keyThemeMode, themeMode);

  // Notifications management
  bool areNotificationsEnabled() => _prefs.getBool(_keyNotifications) ?? true;

  Future<bool> setNotificationsEnabled(bool enabled) =>
      _prefs.setBool(_keyNotifications, enabled);

  // Location services management
  bool isLocationServicesEnabled() =>
      _prefs.getBool(_keyLocationServices) ?? true;

  Future<bool> setLocationServicesEnabled(bool enabled) =>
      _prefs.setBool(_keyLocationServices, enabled);

  // Last sync timestamp
  DateTime? getLastSyncTimestamp() {
    final timestamp = _prefs.getInt(_keyLastSync);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> setLastSyncTimestamp(DateTime timestamp) =>
      _prefs.setInt(_keyLastSync, timestamp.millisecondsSinceEpoch);

  // Generic methods for other preferences
  dynamic get(String key) => _prefs.get(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();
}