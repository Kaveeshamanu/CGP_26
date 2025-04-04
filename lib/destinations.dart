import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DestinationsScreen(),
    );
  }
}

class DestinationsScreen extends StatelessWidget {
  final List<Map<String, String>> destinations = [
    {'name': 'Colombo', 'image': 'assets/colombo.jpg'},
    {'name': 'Kandy', 'image': 'assets/kandy.jpg'},
    {'name': 'Sigiriya', 'image': 'assets/sigiriya.jpg'},
    {'name': 'Anuradhapura', 'image': 'assets/anuradhapura.jpg'},
    {'name': 'Polonnaruwa', 'image': 'assets/polonnaruwa.jpg'},
    {'name': 'Dambulla', 'image': 'assets/dambulla.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destinations'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            return DestinationCard(
              name: destinations[index]['name']!,
              imagePath: destinations[index]['image']!,
            );
          },
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String name;
  final String imagePath;

  DestinationCard({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Icon(
            Icons.favorite_border,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 16),
                  SizedBox(width: 5),
                  Text(
                    '4.8 (1200 viewers)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
