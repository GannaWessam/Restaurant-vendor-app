import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../db/reservations_crud.dart';
import '../models/reservation_model.dart';

class MyReservationsController extends GetxController {
  final ReservationsCrud _reservationsCrud = Get.find<ReservationsCrud>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reactive state
  final RxList<ReservationModel> reservations = <ReservationModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadReservations();
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Load reservations for the current user
  Future<void> loadReservations() async {
    try {
      isLoading.value = true;
      // final userId = currentUserId;
      // if (userId == null) {
      //   reservations.value = [];
      //   isLoading.value = false;
      //   return;
      // }

      final usersReservations = await _reservationsCrud.getReservations();
      reservations.value = usersReservations;
    } catch (e) {
      print('Error loading reservations: $e');
      reservations.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel a reservation
  // Future<void> cancelReservation(String reservationId) async {
  //   try {
  //     await _reservationsCrud.deleteReservation(reservationId);
  //     // Reload reservations after cancellation
  //     await loadReservations();
  //   } catch (e) {
  //     print('Error cancelling reservation: $e');
  //     rethrow;
  //   }
  // }
}

