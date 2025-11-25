/// ReservationModel - Model for storing reservation data
class ReservationModel {
  final String id;
  final String userId; // ID of the user who made the reservation
  final String restaurantName;
  final String restaurantCategory;
  final String timeSlot;
  final int seatCount;
  final List<int> seatIds;
  final DateTime reservationDate; // When the reservation was created
  final DateTime scheduledDate; // When the reservation is scheduled for
  final String? restaurantImage;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.restaurantName,
    required this.restaurantCategory,
    required this.timeSlot,
    required this.seatCount,
    required this.seatIds,
    required this.reservationDate,
    required this.scheduledDate,
    this.restaurantImage,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'restaurantName': restaurantName,
      'restaurantCategory': restaurantCategory,
      'timeSlot': timeSlot,
      'seatCount': seatCount,
      'seatIds': seatIds,
      'reservationDate': reservationDate.toIso8601String(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'restaurantImage': restaurantImage,
    };
  }

  // Create from JSON
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '', // Handle nullable/missing userId
      restaurantName: json['restaurantName'] as String? ?? '',
      restaurantCategory: json['restaurantCategory'] as String? ?? '',
      timeSlot: json['timeSlot'] as String? ?? '',
      seatCount: (json['seatCount'] as num? ?? 0).toInt(),
      seatIds: json['seatIds'] != null ? List<int>.from(json['seatIds']) : [],
      reservationDate: json['reservationDate'] != null 
          ? DateTime.parse(json['reservationDate'] as String)
          : DateTime.now(),
      scheduledDate: json['scheduledDate'] != null 
          ? DateTime.parse(json['scheduledDate'] as String)
          : DateTime.now(),
      restaurantImage: json['restaurantImage'] as String?,
    );
  }
}

