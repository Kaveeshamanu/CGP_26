import 'package:flutter/foundation.dart';

import '../models/place.dart';

class LocationService extends ChangeNotifier {
  List<Place> _places = [];
  bool _isLoading = false;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;

  Future<void> fetchNearbyPlaces(double latitude, double longitude) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Mock data
      _places = [
        Place(
          id: 'place-1',
          name: 'Sigiriya Rock Fortress',
          description: 'An ancient rock fortress and palace ruin in the central Matale District of Sri Lanka.',
          imageUrl: 'https://www.srilankatravelandtourism.com/wp-content/uploads/2020/04/sigiriya-rock-fortress-sri-lanka.jpg',
          latitude: 7.9570,
          longitude: 80.7603,
          category: 'Attraction',
          rating: 4.8,
        ),
        Place(
          id: 'place-2',
          name: 'Galle Fort',
          description: 'A UNESCO World Heritage Site and the largest remaining European-built fortress in Asia.',
          imageUrl: 'https://www.srilankatravelandtourism.com/wp-content/uploads/2020/04/galle-fort-aerial-view.jpg',
          latitude: 6.0267,
          longitude: 80.2170,
          category: 'Attraction',
          rating: 4.7,
        ),
        Place(
          id: 'place-3',
          name: 'Yala National Park',
          description: 'The most visited and second largest national park in Sri Lanka.',
          imageUrl: 'https://www.srilankatravelandtourism.com/wp-content/uploads/2020/04/yala-national-park-safari-leopard.jpg',
          latitude: 6.3735,
          longitude: 81.5088,
          category: 'Nature',
          rating: 4.6,
        ),
        Place(
          id: 'place-4',
          name: 'Nine Arch Bridge',
          description: 'An iconic bridge built during the British colonial period in Sri Lanka.',
          imageUrl: 'https://www.srilankatravelandtourism.com/wp-content/uploads/2020/04/nine-arch-bridge-ella-sri-lanka.jpg',
          latitude: 6.8783,
          longitude: 81.0631,
          category: 'Attraction',
          rating: 4.5,
        ),
        Place(
          id: 'place-5',
          name: 'Temple of the Tooth',
          description: 'A Buddhist temple in the city of Kandy which houses the relic of the tooth of Buddha.',
          imageUrl: 'https://www.srilankatravelandtourism.com/wp-content/uploads/2020/04/temple-of-the-tooth-kandy-sri-lanka.jpg',
          latitude: 7.2936,
          longitude: 80.6413,
          category: 'Temple',
          rating: 4.9,
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error fetching places: $e');
    }
  }

  Future<List<Place>> searchPlaces(String query) async {
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      // Filter existing places based on query
      return _places.where((place) =>
      place.name.toLowerCase().contains(query.toLowerCase()) ||
          place.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
}
