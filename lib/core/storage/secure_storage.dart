// ignore_for_file: avoid_print

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A wrapper for secure storage operations.
/// 
/// This class provides a unified interface for securely storing sensitive data
/// like tokens, credentials, and other secrets.
class SecureStorage {
  final FlutterSecureStorage _storage;
  
  /// Creates a new [SecureStorage] instance.
  /// 
  /// If no [FlutterSecureStorage] is provided, the default instance will be used.
  SecureStorage({FlutterSecureStorage? storage}) 
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );
  
  /// Reads a value from secure storage.
  /// 
  /// [key] is the key to read.
  /// Returns the value associated with the key, or null if it doesn't exist.
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      // Log error but don't throw to prevent app crashes
      print('Error reading from secure storage: $e');
      return null;
    }
  }
  
  /// Writes a value to secure storage.
  /// 
  /// [key] is the key to write.
  /// [value] is the value to write.
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print('Error writing to secure storage: $e');
      rethrow;
    }
  }
  
  /// Deletes a value from secure storage.
  /// 
  /// [key] is the key to delete.
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('Error deleting from secure storage: $e');
      rethrow;
    }
  }
  
  /// Checks if a key exists in secure storage.
  /// 
  /// [key] is the key to check.
  /// Returns true if the key exists, false otherwise.
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      print('Error checking key in secure storage: $e');
      return false;
    }
  }
  
  /// Deletes all values from secure storage.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error deleting all from secure storage: $e');
      rethrow;
    }
  }
  
  /// Reads all values from secure storage.
  /// 
  /// Returns a map of all keys and values in secure storage.
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      print('Error reading all from secure storage: $e');
      return {};
    }
  }

  getCurrentUser() {}
}