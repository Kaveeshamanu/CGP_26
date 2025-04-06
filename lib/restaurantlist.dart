import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurants',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RestaurantListScreen(),
    );
  }
}

class Restaurant {
  final String name;
  final String location;
  final double rating;
  final String reviews;
  final String imagePath;
  bool isFavorite;

  Restaurant({
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.imagePath,
    this.isFavorite = false,
  });
}

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final List<Restaurant> restaurants = [
    Restaurant(
        name: 'Cafe Chill',
        location: 'Colombo',
        rating: 4.2,
        reviews: '(1500 reviews)',
        imagePath: 'assets/cafe_chill.jpeg'),
    Restaurant(
        name: 'Bavarian German Restaurant',
        location: 'Colombo',
        rating: 4.1,
        reviews: '(1100 reviews)',
        imagePath: 'assets/bavarian_german.jpeg'),
    Restaurant(
        name: 'Street Burger Co.',
        location: 'Colombo',
        rating: 4.0,
        reviews: '(1320 reviews)',
        imagePath: 'assets/street_burger.jpeg'),
    Restaurant(
        name: 'Pilawoos',
        location: 'Colombo',
        rating: 4.0,
        reviews: '(1220 reviews)',
        imagePath: 'assets/pilawoos.jpeg'),
    Restaurant(
        name: 'The Commons',
        location: 'Colombo',
        rating: 4.0,
        reviews: '(1220 reviews)',
        imagePath: 'assets/commons.jpeg'),
    Restaurant(
        name: 'Bombay Sweet Mahal',
        location: 'Colombo',
        rating: 4.0,
        reviews: '(1220 reviews)',
        imagePath: 'assets/bombay_sweets.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  return _buildRestaurantCard(restaurants[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF232838),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () {},
          ),
          const Text(
            'Restaurants',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            restaurant.imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          restaurant.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(restaurant.location, style: const TextStyle(color: Colors.grey)),
            Text('${restaurant.rating} ⭐ ${restaurant.reviews}',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            restaurant.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: restaurant.isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              restaurant.isFavorite = !restaurant.isFavorite;
            });
          },
        ),
      ),
    );
  }
}