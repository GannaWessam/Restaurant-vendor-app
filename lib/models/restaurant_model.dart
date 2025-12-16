/// RestaurantModel - Model in MVVM pattern
/// Represents restaurant data structure
class RestaurantModel {
  final String id;
  final String name;
  final String category;
  final String distance;
  final double rating;
  final String tables;
  final String? imageBase64; // Changed from imagePath to imageBase64 for Firestore storage
  final String? description;
  final List<String> timeSlots;
  final double? latitude;
  final double? longitude;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.rating,
    required this.tables,
    this.imageBase64, // Changed from imagePath to imageBase64
    this.description,
    required this.timeSlots,
    this.latitude,
    this.longitude,
  });

  // Convert RestaurantModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'distance': distance,
      'rating': rating,
      'tables': tables,
      'imageBase64': imageBase64, // Changed from imagePath to imageBase64
      'description': description,
      'timeSlots': timeSlots,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create RestaurantModel from JSON
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      distance: json['distance'] as String? ?? 'Unknown distance',
      rating: (json['rating'] as num? ?? 0).toDouble(),
      tables: json['tables'] as String? ?? '0 tables',
      imageBase64: json['imageBase64'] as String?, // Changed from imagePath to imageBase64
      description: json['description'] as String?,
      timeSlots: json['timeSlots'] != null
          ? List<String>.from(json['timeSlots'])
          : ['7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  // Create a copy of the restaurant with some fields updated
  RestaurantModel copyWith({
    String? id,
    String? name,
    String? category,
    String? distance,
    double? rating,
    String? tables,
    String? imageBase64, // Changed from imagePath to imageBase64
    String? description,
    List<String>? timeSlots,
    double? latitude,
    double? longitude,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      tables: tables ?? this.tables,
      imageBase64: imageBase64 ?? this.imageBase64, // Changed from imagePath to imageBase64
      description: description ?? this.description,
      timeSlots: timeSlots ?? this.timeSlots,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

