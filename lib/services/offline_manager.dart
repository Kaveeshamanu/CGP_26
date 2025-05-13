import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/place.dart';

class OfflineManager extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isOfflineMode = false;
  List<String> _downloadedRegions = [];

  OfflineManager(this._prefs) {
    _loadOfflineSettings();
  }

  bool get isOfflineMode => _isOfflineMode;
  List<String> get downloadedRegions => _downloadedRegions;

  void _loadOfflineSettings() {
    _isOfflineMode = _prefs.getBool('offline_mode') ?? false;
    _downloadedRegions = _prefs.getStringList('downloaded_regions') ?? [];
    notifyListeners();
  }

  Future<void> toggleOfflineMode(bool value) async {
    _isOfflineMode = value;
    await _prefs.setBool('offline_mode', value);
    notifyListeners();
  }

  Future<bool> downloadRegion(String regionName, List<Place> places) async {
    try {
      // In a real app, you would download map tiles and other data here

      // For this demo, we'll just save the places to SharedPreferences
      final placesJson = json.encode(places.map((p) => p.toJson()).toList());
      await _prefs.setString('offline_places_$regionName', placesJson);

      // Add region to downloaded regions
      _downloadedRegions.add(regionName);
      await _prefs.setStringList('downloaded_regions', _downloadedRegions);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error downloading region: $e');
      return false;
    }
  }

  Future<bool> removeDownloadedRegion(String regionName) async {
    try {
      // Remove cached data
      await _prefs.remove('offline_places_$regionName');

      // Remove from downloaded regions
      _downloadedRegions.removeWhere((region) => region == regionName);
      await _prefs.setStringList('downloaded_regions', _downloadedRegions);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error removing downloaded region: $e');
      return false;
    }
  }

  Future<List<Place>> getOfflinePlaces(String regionName) async {
    try {
      final placesJson = _prefs.getString('offline_places_$regionName');
      if (placesJson == null) return [];

      final placesList = json.decode(placesJson) as List;
      return placesList.map((placeJson) => Place.fromJson(placeJson)).toList();
    } catch (e) {
      print('Error getting offline places: $e');
      return [];
    }
  }
}
