import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> destinations = const [
    {"name": "Colombo", "image": "assets/colombo.jpg"},
    {"name": "Kandy", "image": "assets/kandy.jpg"},
    {"name": "Sigiriya", "image": "assets/sigiriya.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome John",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                Text("@Maharagama",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.pink)),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications, color: Colors.pink)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                CategoryButton(title: "Destinations"),
                CategoryButton(title: "Hotels"),
                CategoryButton(title: "Transports"),
                CategoryButton(title: "Itinerary"),
              ],
            ),
            const SizedBox(height: 20),

            // Most Popular Title
            const Text("Most Popular",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Destination List
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  return DestinationCard(destination: destinations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Category Button (Outlined)
class CategoryButton extends StatelessWidget {
  final String title;
  const CategoryButton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(title, style: const TextStyle(fontSize: 12)),
    );
  }
}

// Destination Card with Favorite Icon
class DestinationCard extends StatelessWidget {
  final Map<String, String> destination;
  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        children: [
          Image.asset(
            destination["image"] ?? "assets/placeholder.jpg",
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(Icons.favorite_border, color: Colors.red, size: 20),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination["name"] ?? "Unknown",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.red, size: 16),
                    Text(" 4.8 (1200 viewers)",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
