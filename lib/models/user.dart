class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String>? preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      preferences: json['preferences'] != null
          ? List<String>.from(json['preferences'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'preferences': preferences,
    };
  }
}