import 'package:flutter/foundation.dart';

import '../models/accommodation.dart';

class BookingService extends ChangeNotifier {
  List<Accommodation> _accommodations = [];
  bool _isLoading = false;

  List<Accommodation> get accommodations => _accommodations;
  bool get isLoading => _isLoading;

  Future<void> fetchAccommodations() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // Mock data
      _accommodations = [
        Accommodation(
          id: 'acc-1',
          name: 'Amari Galle',
          description: 'Luxury beachfront resort near Galle Fort with stunning ocean views.',
          imageUrl: 'https://cf.bstatic.com/xdata/images/hotel/max1024x768/275421254.jpg?k=e5afe70073be7bc30b9ff9cbe8a40f5bc9b89f5c24ee9a7578b32ce14b322c35&o=&hp=1',
          latitude: 6.0331,
          longitude: 80.2184,
          price: 250.00,
          type: 'Resort',
          rating: 4.8,
          amenities: ['Pool', 'Spa', 'WiFi', 'Restaurant', 'Beach Access'],
        ),
        Accommodation(
          id: 'acc-2',
          name: 'Cinnamon Red Colombo',
          description: 'Modern hotel in the heart of Colombo with rooftop infinity pool.',
          imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/1c/d5/44/d4/cinnamon-red-colombo.jpg?w=1200&h=-1&s=1',
          latitude: 6.9147,
          longitude: 79.8515,
          price: 120.00,
          type: 'Hotel',
          rating: 4.5,
          amenities: ['Pool', 'WiFi', 'Restaurant', 'Gym', 'City Views'],
        ),
        Accommodation(
          id: 'acc-3',
          name: 'Ella Flower Garden Resort',
          description: 'Charming hillside resort with breathtaking mountain views.',
          imageUrl: 'https://cf.bstatic.com/xdata/images/hotel/max1024x768/240581974.jpg?k=9539e5b5128f20a40c7a6cfe5d77de729ca5dde8d349bf85d61bad0367517b3c&o=&hp=1',
          latitude: 6.8712,
          longitude: 81.0460,
          price: 85.00,
          type: 'Resort',
          rating: 4.6,
          amenities: ['WiFi', 'Restaurant', 'Mountain Views', 'Garden'],
        ),
        Accommodation(
          id: 'acc-4',
          name: 'Clock Inn Colombo',
          description: 'Budget-friendly hostel with clean, comfortable accommodations.',
          imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/06/1b/ba/21/clock-inn-colombo.jpg?w=1200&h=-1&s=1',
          latitude: 6.9271,
          longitude: 79.8612,
          price: 20.00,
          type: 'Hostel',
          rating: 4.2,
          amenities: ['WiFi', 'Shared Kitchen', 'Common Area', 'Lockers'],
        ),
        Accommodation(
          id: 'acc-5',
          name: 'The Kandy House',
          description: 'Boutique heritage hotel in a restored Sri Lankan manor house.',
          imageUrl: 'https://cf.bstatic.com/xdata/images/hotel/max1024x768/199799207.jpg?k=e19c4923b3254182bc9c9a78f9d0f7c2f5e29f572d91ad86b9a3c5634cf4961c&o=&hp=1',
          latitude: 7.2905,
          longitude: 80.6343,
          price: 180.00,
          type: 'Boutique Hotel',
          rating: 4.9,
          amenities: ['Pool', 'Garden', 'WiFi', 'Restaurant', 'Historic Building'],
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error fetching accommodations: $e');
    }
  }

  Future<bool> bookAccommodation(String accommodationId, DateTime checkIn, DateTime checkOut, int guests) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      // In a real app, you would call your booking API here

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error booking accommodation: $e');
      return false;
    }
  }
}