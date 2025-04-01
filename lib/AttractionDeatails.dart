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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AttractionsPageDetails(),
    );
  }
}

class AttractionsPageDetails extends StatelessWidget {
  const AttractionsPageDetails({super.key});

  final List<Map<String, dynamic>> attractions = const [
    {
      "name": "Jami Ul-Alfar Mosque",
      "location": "Colombo",
      "rating": 4.8,
      "reviews": 1200,
      "image": "assets/images/Gangaramaya.jpg", // Ensure this path exists
      "description": "The Jami Ul-Alfar Mosque, also known as the Red Mosque, is a historic and iconic landmark in Colombo, Sri Lanka...",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attractions")),
      body: ListView.builder(
        itemCount: attractions.length,
        itemBuilder: (context, index) {
          var attraction = attractions[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttractionDetailPage(
                    name: attraction["name"],
                    location: attraction["location"],
                    rating: attraction["rating"],
                    reviews: attraction["reviews"],
                    image: attraction["image"],
                    description: attraction["description"],
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                        attraction["image"],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover
                    ),
                  ),
                  ListTile(
                    title: Text(attraction["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${attraction["location"]} • ⭐ ${attraction["rating"]} (${attraction["reviews"]} reviews)"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AttractionDetailPage extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final String image;
  final String description;

  const AttractionDetailPage({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.image,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
                image,
                fit: BoxFit.cover
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(location, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 20),
                          const SizedBox(width: 5),
                          Text("$rating ($reviews reviews)", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.map),
                            label: const Text("View on Map"),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.place),
                            label: const Text("Nearby Attractions"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
