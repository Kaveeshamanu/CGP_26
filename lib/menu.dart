import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RestaurantMenuScreen(),
  ));
}

class RestaurantMenuScreen extends StatelessWidget {
  RestaurantMenuScreen({super.key});

  final List<Map<String, String>> menuItems = [
    {
      'name': '1.0',
      'description': 'Signature marinated crispy chicken breast, melted cheddar cheese, sriracha sauce, shredded iceberg lettuce, spicy mayo topped with our signature sauces on a toasted bun.',
      'image': 'assets/burger1.jpeg',
    },
    {
      'name': 'HOT SILENCER',
      'description': 'Crispy fried chicken breast, shredded iceberg lettuce, red onions, melted cheddar cheese hot sauce topped with our signature sauces on a toasted bun.',
      'image': 'assets/burger2.jpeg',
    },
    {
      'name': 'BBQ PISTON CRISPY',
      'description': 'Crispy fried chicken breast, shredded iceberg lettuce, red onions, melted cheddar cheese, crispy onion rings, smoky BBQ sauce topped with our signature sauces on a toasted bun.',
      'image': 'assets/burger3.jpeg',
    },
    {
      'name': 'F1',
      'description': 'Note: Bunless burger\nDouble crispy fried chicken breast, melted cheddar cheese, smoky BBQ sauce, Chicken bacon and mayo dip on the side.',
      'image': 'assets/burger4.jpeg',
    },
    {
      'name': 'FIREBIRD',
      'description': 'Crispy fried chicken breast, shredded iceberg lettuce, melted cheddar cheese, pickled red paprika, topped with our sauces on a toasted bun.',
      'image': 'assets/burger5.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Street Burger Co.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Now Open', style: TextStyle(color: Colors.green)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOfferBadge('10% for takeaway'),
                _buildOfferBadge('Buy 1 get 1 for free'),
              ],
            ),
            SizedBox(height: 20),
            Text('Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return _buildMenuItem(menuItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 14)),
    );
  }

  Widget _buildMenuItem(Map<String, String> item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name']!,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(item['description']!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ],
              ),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(item['image']!, width: 80, height: 80, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}