import 'package:flutter/material.dart';

import 'AttractionDeatails.dart';
// Import the details page

class AttractionsPage extends StatelessWidget {
  final List<Map<String, dynamic>> attractions = [
    {
      'name': 'Gangaramaya Temple',
      'image': 'assets/images/Gangaramaya.jpg',
      'location': 'Colombo',
      'rating': 4.8,
      'reviews': 1200,
      'description': 'A beautiful Buddhist temple with a mix of modern and traditional architecture...'
    },
    {
      'name': 'Lotus Tower',
      'image': 'assets/images/Lotus_Tower.jpg',
      'location': 'Colombo',
      'rating': 4.7,
      'reviews': 980,
      'description': 'The tallest self-supported structure in South Asia, offering stunning views...'
    },
    {
      'name': 'Jami Ul-Alfar Mosque',
      'image': 'assets/images/Jami.jpeg',
      'location': 'Colombo',
      'rating': 4.8,
      'reviews': 1200,
      'description': 'The Jami Ul-Alfar Mosque, also known as the Red Mosque, is a historic and iconic landmark...'
    },
    {
      'name': 'Galle Face',
      'image': 'assets/images/galleface.jpg',
      'location': 'Colombo',
      'rating': 4.6,
      'reviews': 1500,
      'description': 'A popular ocean-side urban park in Colombo, perfect for sunset walks...'
    },
    {
      'name': 'Aluthkade',
      'image': 'assets/images/Aluthkade.jpeg',
      'location': 'Colombo',
      'rating': 4.5,
      'reviews': 900,
      'description': 'Famous for its street food and vibrant nightlife...'
    },
    {
      'name': 'Viharamahadevi Park',
      'image': 'assets/images/Viharamahadevi.jpg',
      'location': 'Colombo',
      'rating': 4.6,
      'reviews': 1100,
      'description': 'A large public park featuring a Buddha statue and beautiful green landscapes...'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attractions'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: attractions.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttractionDetailPage(
                      name: attractions[index]['name'],
                      location: attractions[index]['location'],
                      rating: attractions[index]['rating'],
                      reviews: attractions[index]['reviews'],
                      image: attractions[index]['image'],
                      description: attractions[index]['description'],
                    ),
                  ),
                );
              },
              child: AttractionCard(
                name: attractions[index]['name'],
                image: attractions[index]['image'],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AttractionCard extends StatelessWidget {
  final String name;
  final String image;

  const AttractionCard({required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.favorite_border,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(5),
              color: Colors.black54,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
