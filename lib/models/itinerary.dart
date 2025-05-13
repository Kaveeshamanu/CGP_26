class Itinerary {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<ItineraryActivity> activities;
  final String userId;

  Itinerary({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.activities,
    required this.userId,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      activities: (json['activities'] as List)
          .map((activity) => ItineraryActivity.fromJson(activity))
          .toList(),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'userId': userId,
    };
  }
}

class ItineraryActivity {
  final String id;
  final String name;
  final String placeId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  ItineraryActivity({
    required this.id,
    required this.name,
    required this.placeId,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      id: json['id'],
      name: json['name'],
      placeId: json['placeId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'placeId': placeId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'notes': notes,
    };
  }
}