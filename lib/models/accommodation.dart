class Accommodation {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double price;
  final String type; // hotel, hostel, resort, villa
  final double rating;
  final List<String> amenities;
  final List<String>? images;

  Accommodation({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.type,
    required this.rating,
    required this.amenities,
    this.images,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      price: json['price'].toDouble(),
      type: json['type'],
      rating: json['rating'].toDouble(),
      amenities: List<String>.from(json['amenities']),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'type': type,
      'rating': rating,
      'amenities': amenities,
      'images': images,
    };
  }
}