import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taprobana_trails/config/constants.dart';

/// A wrapper for local storage operations.
///
/// This class provides a unified interface for storing non-sensitive data
/// like user preferences, app state, and cached data.
class LocalStorage {
  final SharedPreferences _preferences;
  
  /// Creates a new [LocalStorage] instance.
  /// 
  /// If no [SharedPreferences] is provided, the instance must be initialized
  /// with [LocalStorage.initialize] before use.
  LocalStorage._(this._preferences);
  
  /// Initializes the local storage.
  /// 
  /// This must be called before using any storage methods if the constructor
  /// was not provided with a [SharedPreferences] instance.
  static Future<LocalStorage> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorage._(preferences);
  }
  
  /// Gets a String value from local storage.
  /// 
  /// [key] is the key to read.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  String getString(String key, {String defaultValue = ''}) {
    return _preferences.getString(key) ?? defaultValue;
  }
  
  /// Sets a String value in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  Future<bool> setString(String key, String value) async {
    return await _preferences.setString(key, value);
  }
  
  /// Gets an int value from local storage.
  /// 
  /// [key] is the key to read.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  int getInt(String key, {int defaultValue = 0}) {
    return _preferences.getInt(key) ?? defaultValue;
  }
  
  /// Sets an int value in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  Future<bool> setInt(String key, int value) async {
    return await _preferences.setInt(key, value);
  }
  
  /// Gets a double value from local storage.
  /// 
  /// [key] is the key to read.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _preferences.getDouble(key) ?? defaultValue;
  }
  
  /// Sets a double value in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  Future<bool> setDouble(String key, double value) async {
    return await _preferences.setDouble(key, value);
  }
  
  /// Gets a bool value from local storage.
  /// 
  /// [key] is the key to read.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences.getBool(key) ?? defaultValue;
  }
  
  /// Sets a bool value in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  Future<bool> setBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }
  
  /// Gets a list of strings from local storage.
  /// 
  /// [key] is the key to read.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _preferences.getStringList(key) ?? defaultValue;
  }
  
  /// Sets a list of strings in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences.setStringList(key, value);
  }
  
  /// Gets a map from local storage.
  /// 
  /// [key] is the key to read.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  Map<String, dynamic> getMap(String key, {Map<String, dynamic> defaultValue = const {}}) {
    final string = _preferences.getString(key);
    
    if (string == null) {
      return defaultValue;
    }
    
    try {
      return jsonDecode(string) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding map: $e');
      return defaultValue;
    }
  }
  
  /// Sets a map in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  Future<bool> setMap(String key, Map<String, dynamic> value) async {
    try {
      final string = jsonEncode(value);
      return await _preferences.setString(key, string);
    } catch (e) {
      debugPrint('Error encoding map: $e');
      return false;
    }
  }
  
  /// Gets a list of maps from local storage.
  /// 
  /// [key] is the key to read.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  List<Map<String, dynamic>> getMapList(
    String key, {
    List<Map<String, dynamic>> defaultValue = const [],
  }) {
    final string = _preferences.getString(key);
    
    if (string == null) {
      return defaultValue;
    }
    
    try {
      final list = jsonDecode(string) as List;
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error decoding map list: $e');
      return defaultValue;
    }
  }
  
  /// Sets a list of maps in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  Future<bool> setMapList(String key, List<Map<String, dynamic>> value) async {
    try {
      final string = jsonEncode(value);
      return await _preferences.setString(key, string);
    } catch (e) {
      debugPrint('Error encoding map list: $e');
      return false;
    }
  }
  
  /// Gets an object from local storage.
  /// 
  /// [key] is the key to read.
  /// [fromJson] is a function that creates an object from JSON.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  T? getObject<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson, {
    T? defaultValue,
  }) {
    final string = _preferences.getString(key);
    
    if (string == null) {
      return defaultValue;
    }
    
    try {
      final json = jsonDecode(string) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      debugPrint('Error decoding object: $e');
      return defaultValue;
    }
  }
  
  /// Sets an object in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  /// [toJson] is a function that converts an object to JSON.
  Future<bool> setObject<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T value) toJson,
  ) async {
    try {
      final json = toJson(value);
      final string = jsonEncode(json);
      return await _preferences.setString(key, string);
    } catch (e) {
      debugPrint('Error encoding object: $e');
      return false;
    }
  }
  
  /// Gets a list of objects from local storage.
  /// 
  /// [key] is the key to read.
  /// [fromJson] is a function that creates an object from JSON.
  /// [defaultValue] is the value to return if the key doesn't exist.
  /// Returns the value associated with the key, or [defaultValue] if it doesn't exist.
  List<T> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson, {
    List<T> defaultValue = const [],
  }) {
    final string = _preferences.getString(key);
    
    if (string == null) {
      return defaultValue;
    }
    
    try {
      final list = jsonDecode(string) as List;
      return list
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error decoding object list: $e');
      return defaultValue;
    }
  }
  
  /// Sets a list of objects in local storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  /// [toJson] is a function that converts an object to JSON.
  Future<bool> setObjectList<T>(
    String key,
    List<T> value,
    Map<String, dynamic> Function(T value) toJson,
  ) async {
    try {
      final list = value.map((item) => toJson(item)).toList();
      final string = jsonEncode(list);
      return await _preferences.setString(key, string);
    } catch (e) {
      debugPrint('Error encoding object list: $e');
      return false;
    }
  }
  
  /// Checks if a key exists in local storage.
  /// 
  /// [key] is the key to check.
  /// Returns true if the key exists, false otherwise.
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }
  
  /// Removes a value from local storage.
  /// 
  /// [key] is the key to remove.
  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }
  
  /// Clears all values from local storage.
  Future<bool> clear() async {
    return await _preferences.clear();
  }
  
  /// Gets all keys from local storage.
  Set<String> getKeys() {
    return _preferences.getKeys();
  }
  
  /// Saves a file to the app's documents directory.
  /// 
  /// [fileName] is the name of the file.
  /// [bytes] is the file contents as bytes.
  /// [subdirectory] is an optional subdirectory to store the file in.
  /// Returns the path to the saved file.
  Future<String> saveFile(
    String fileName,
    Uint8List bytes, {
    String? subdirectory,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      final filePath = subdirectory != null
          ? '${directory.path}/$subdirectory/$fileName'
          : '${directory.path}/$fileName';
      
      // Create subdirectory if it doesn't exist
      if (subdirectory != null) {
        final subDir = Directory('${directory.path}/$subdirectory');
        if (!await subDir.exists()) {
          await subDir.create(recursive: true);
        }
      }
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      debugPrint('Error saving file: $e');
      rethrow;
    }
  }
  
  /// Reads a file from the app's documents directory.
  /// 
  /// [fileName] is the name of the file.
  /// [subdirectory] is an optional subdirectory where the file is stored.
  /// Returns the file contents as bytes.
  Future<Uint8List?> readFile(
    String fileName, {
    String? subdirectory,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      final filePath = subdirectory != null
          ? '${directory.path}/$subdirectory/$fileName'
          : '${directory.path}/$fileName';
      
      final file = File(filePath);
      
      if (!await file.exists()) {
        return null;
      }
      
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Error reading file: $e');
      return null;
    }
  }
  
  /// Deletes a file from the app's documents directory.
  /// 
  /// [fileName] is the name of the file.
  /// [subdirectory] is an optional subdirectory where the file is stored.
  Future<bool> deleteFile(
    String fileName, {
    String? subdirectory,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      final filePath = subdirectory != null
          ? '${directory.path}/$subdirectory/$fileName'
          : '${directory.path}/$fileName';
      
      final file = File(filePath);
      
      if (!await file.exists()) {
        return false;
      }
      
      await file.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
  
  /// Checks if a file exists in the app's documents directory.
  /// 
  /// [fileName] is the name of the file.
  /// [subdirectory] is an optional subdirectory where the file is stored.
  Future<bool> fileExists(
    String fileName, {
    String? subdirectory,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      final filePath = subdirectory != null
          ? '${directory.path}/$subdirectory/$fileName'
          : '${directory.path}/$fileName';
      
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking if file exists: $e');
      return false;
    }
  }
  
  /// Gets the size of a file in bytes.
  /// 
  /// [fileName] is the name of the file.
  /// [subdirectory] is an optional subdirectory where the file is stored.
  Future<int> getFileSize(
    String fileName, {
    String? subdirectory,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      final filePath = subdirectory != null
          ? '${directory.path}/$subdirectory/$fileName'
          : '${directory.path}/$fileName';
      
      final file = File(filePath);
      
      if (!await file.exists()) {
        return 0;
      }
      
      return await file.length();
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }
  
  /// Gets the total size of the app's documents directory in bytes.
  Future<int> getTotalStorageSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error getting total storage size: $e');
      return 0;
    }
  }
  
  /// Gets the app's cache directory.
  Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }
  
  /// Clears the app's cache directory.
  Future<bool> clearCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          await entity.delete(recursive: true);
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      return false;
    }
  }
  
  /// Gets the size of the app's cache directory in bytes.
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getCacheDirectory();
      
      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error getting cache size: $e');
      return 0;
    }
  }
  
  /// Gets the path to the app's documents directory.
  Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  /// Gets a dark mode preference from local storage.
  bool getDarkMode() {
    return getBool(StorageKeys.isDarkMode);
  }
  
  /// Sets a dark mode preference in local storage.
  Future<bool> setDarkMode(bool value) async {
    return await setBool(StorageKeys.isDarkMode, value);
  }
  
  /// Gets the preferred language from local storage.
  String getPreferredLanguage() {
    return getString(StorageKeys.preferredLanguage, defaultValue: 'en');
  }
  
  /// Sets the preferred language in local storage.
  Future<bool> setPreferredLanguage(String value) async {
    return await setString(StorageKeys.preferredLanguage, value);
  }
  
  /// Gets the preferred currency from local storage.
  String getPreferredCurrency() {
    return getString(StorageKeys.preferredCurrency, defaultValue: 'LKR');
  }
  
  /// Sets the preferred currency in local storage.
  Future<bool> setPreferredCurrency(String value) async {
    return await setString(StorageKeys.preferredCurrency, value);
  }
  
  /// Gets whether the user has completed onboarding.
  bool getHasCompletedOnboarding() {
    return getBool(StorageKeys.hasCompletedOnboarding);
  }
  
  /// Sets whether the user has completed onboarding.
  Future<bool> setHasCompletedOnboarding(bool value) async {
    return await setBool(StorageKeys.hasCompletedOnboarding, value);
  }
  
  /// Gets the last search query from local storage.
  String getLastSearchQuery() {
    return getString(StorageKeys.lastSearchQuery);
  }
  
  /// Sets the last search query in local storage.
  Future<bool> setLastSearchQuery(String value) async {
    return await setString(StorageKeys.lastSearchQuery, value);
  }
  
  /// Gets recent searches from local storage.
  List<String> getRecentSearches() {
    return getStringList(StorageKeys.recentSearches);
  }
  
  /// Adds a search query to recent searches.
  Future<bool> addToRecentSearches(String query) async {
    final searches = getRecentSearches();
    
    // Remove the query if it already exists
    searches.remove(query);
    
    // Add the query to the beginning of the list
    searches.insert(0, query);
    
    // Limit the list to 10 items
    if (searches.length > 10) {
      searches.removeLast();
    }
    
    return await setStringList(StorageKeys.recentSearches, searches);
  }
  
  /// Clears recent searches.
  Future<bool> clearRecentSearches() async {
    return await remove(StorageKeys.recentSearches);
  }
  
  /// Gets the push notification settings.
  bool getPushNotificationEnabled() {
    return getBool(StorageKeys.enablePushNotifications, defaultValue: true);
  }
  
  /// Sets the push notification settings.
  Future<bool> setPushNotificationEnabled(bool value) async {
    return await setBool(StorageKeys.enablePushNotifications, value);
  }
}