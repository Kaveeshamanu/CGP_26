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
      home:  HotelListScreen(),
    );
  }
}

class HotelListScreen extends StatelessWidget {
  HotelListScreen({super.key});

  final List<Map<String, dynamic>> hotels = [
    {
      "name": "Clock Inn Colombo",
      "rating": 4.8,
      "reviews": 1333,
      "price": 00.00,
      "image": "assets/hotel1.jpg",
      "stars": 3,
    },
    {
      "name": "City Beds Fort Hotel",
      "rating": 4,
      "reviews": 203,
      "price": 00.00,
      "image": "assets/hotel2.jpg",
      "stars": 3,
    },
    {
      "name": "Taj Samudra",
      "rating": 4,
      "reviews": 1200,
      "price": 45.00,
      "image": "assets/hotel3.jpg",
      "stars": 5,
    },
    {
      "name": "Cinnamon Lakeside Colombo",
      "rating": 3,
      "reviews": 450,
      "price": 50.00,
      "image": "assets/hotel4.jpg",
      "stars":5,
    },
    {
      "name": "Cinnamon Red Colombo",
      "rating": 5,
      "reviews": 980,
      "price": 90.00,
      "image": "assets/hotel5.jpg",
      "stars": 4,
    },
    {
      "name": "Ramada Colombo",
      "rating": 3,
      "reviews": 890,
      "price": 75.00,
      "image": "assets/hotel6.jpg",
      "stars": 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Hotels",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return Card(
                color:Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              hotel["image"],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hotel["name"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      "${hotel["stars"]} star",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.star, color: Colors.orange,
                                            size: 16),
                                        Text(
                                          " ${hotel['rating']}  (${hotel['reviews']} viewers)",
                                          style: TextStyle(fontSize: 14,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                                20),
                                          ),
                                          child: Text(
                                            "Rs. ${hotel['price']}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.favorite_border,
                                              color: Colors.pinkAccent),
                                          onPressed: () {},
                                        ),
                                        const Icon(
                                            Icons.arrow_forward_ios, size: 16,
                                            color: Colors.grey),

                                      ],
                                    ),
                                  ],
                              ),
                          ),
                          ],
                      ),
                  ),
              );

            },
        ),
      ),
    );
  }
}
