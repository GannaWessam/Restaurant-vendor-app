/// RestaurantModel - Model in MVVM pattern
/// Represents restaurant data structure
class RestaurantModel {
  final String id;
  final String name;
  final String category;
  final String distance;
  final double rating;
  final String tables;
  final String? imagePath;
  final String? description;
  final List<String> timeSlots;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.rating,
    required this.tables,
    this.imagePath,
    this.description,
    required this.timeSlots,
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
      'imagePath': imagePath,
      'description': description,
      'timeSlots': timeSlots,
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
      imagePath: json['imagePath'] as String?,
      description: json['description'] as String?,
      timeSlots: json['timeSlots'] != null 
          ? List<String>.from(json['timeSlots'])
          : ['7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM'],
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
    String? imagePath,
    String? description,
    List<String>? timeSlots,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      tables: tables ?? this.tables,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }
}

