import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DestinationDetails(),
  ));
}

class DestinationDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top Image
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/colombo.jpg"), // Change this to your asset
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back & Favorite Icons
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () {},
              ),
            ),
          ),

          // Bottom Details Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination Name & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Colombo",
                        style: TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.red, size: 20),
                          Text(
                            " 4.8 (1200 viewers)",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Description
                  Text(
                    "Colombo, the vibrant capital of Sri Lanka, is a bustling metropolis blending colonial charm with modern urban life.\n\n"
                        "Key attractions include the Colombo National Museum, Gangaramaya Temple, and the bustling Pettah Market. "
                        "With a diverse culinary scene, luxury hotels, and a rich history influenced by Portuguese, Dutch, and British rule, "
                        "Colombo offers a dynamic blend of tradition and contemporary lifestyle.",
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                  SizedBox(height: 15),

                  // Ratings & Reviews Section
                  Text("Ratings & Reviews", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 18,
                        child: Icon(Icons.person, color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("John", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow, size: 14),
                              Icon(Icons.star, color: Colors.yellow, size: 14),
                              Icon(Icons.star, color: Colors.yellow, size: 14),
                              Icon(Icons.star, color: Colors.yellow, size: 14),
                              Icon(Icons.star_half, color: Colors.yellow, size: 14),
                              Text(" 4.5", style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                          Text('"Beautiful city with great food!"', style: TextStyle(color: Colors.white60)),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 15),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          child: Text("View on Map", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          child: Text("Nearby Attractions", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
