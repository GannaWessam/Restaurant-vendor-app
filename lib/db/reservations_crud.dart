import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/reservation_model.dart';
import 'db_instance.dart';

class ReservationsCrud {
  // final FirebaseFirestore firestore = Get.find<CloudDb>().db;
  // Lazy initialization - only access Firestore when firestore is first accessed
  FirebaseFirestore get firestore => Get.find<CloudDb>().db;

  // Future<void> addReservation(ReservationModel reservation) async {
  //   try {
  //     await firestore.collection('reservations').doc(reservation.id).set(reservation.toJson());
  //     print('Reservation added: ${reservation.id}');
  //   } catch (e) {
  //     print('Error adding reservation: $e');
  //   }
  // }

  Future<List<ReservationModel>> getReservations() async { //lel vendor
    try {
      final reservationsSnapshot = await firestore.collection('reservations').get();
      return reservationsSnapshot.docs.map((reservation)=>
          ReservationModel.fromJson(reservation.data())).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<ReservationModel>> getReservationsByUserId(String userId) async { //lel user
    try {
      final reservationsSnapshot =
        await firestore.collection('reservations').where('userId', isEqualTo: userId).get();
      return reservationsSnapshot.docs.map((reservation)=>
          ReservationModel.fromJson(reservation.data())).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Get reservations by restaurant and time slot
  Future<List<ReservationModel>> getReservationsByRestaurantAndTimeSlot(String restaurantName, String timeSlot,) async {
    try {
      final reservationsSnapshot = await firestore
          .collection('reservations')
          .where('restaurantName', isEqualTo: restaurantName)
          .where('timeSlot', isEqualTo: timeSlot)
          .get();
      return reservationsSnapshot.docs
          .map((reservation) => ReservationModel.fromJson(reservation.data()))
          .toList();
    } catch (e) {
      print('Error getting reservations by restaurant and time slot: $e');
      return [];
    }
  }

  // Delete a reservation
  // Future<void> deleteReservation(String reservationId) async {
  //   try {
  //     await firestore.collection('reservations').doc(reservationId).delete();
  //     print('Reservation deleted: $reservationId');
  //   } catch (e) {
  //     print('Error deleting reservation: $e');
  //     rethrow;
  //   }
  // }
}