class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? imageBase64;
  final int restaurantCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.imageBase64,
    this.restaurantCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageBase64': imageBase64,
      'restaurantCount': restaurantCount,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageBase64: json['imageBase64'] as String?,
      restaurantCount: (json['restaurantCount'] as num?)?.toInt() ?? 0,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageBase64,
    int? restaurantCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageBase64: imageBase64 ?? this.imageBase64,
      restaurantCount: restaurantCount ?? this.restaurantCount,
    );
  }
}


