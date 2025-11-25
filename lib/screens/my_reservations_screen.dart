import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/my_reservations_controller.dart';
import '../models/reservation_model.dart';


class MyReservationsScreen extends GetView<MyReservationsController> {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    // if (controller.currentUserId == null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Get.toNamed('/login');
    //   });
    //   return Scaffold(
    //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    //     body: const Center(child: CircularProgressIndicator()),
    //   );
    // }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My Reservations',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),

            // Reservations List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.reservations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Reservations Yet',
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your reservations will appear here',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = controller.reservations[index];
                    return _buildReservationCard(context, reservation);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    ReservationModel reservation,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Name and Category
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    image: reservation.restaurantImage != null
                        ? DecorationImage(
                            image: AssetImage(reservation.restaurantImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: reservation.restaurantImage == null
                      ? Icon(
                          Icons.restaurant,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.restaurantName,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.restaurantCategory,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Confirmed',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),

            // Reservation Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.access_time,
                    'Time',
                    reservation.timeSlot,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.calendar_today,
                    'Date',
                    _formatDate(reservation.scheduledDate),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Seats Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8D6E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8D6E63).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_seat,
                    color: const Color(0xFF8D6E63),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reserved Seats',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reservation.seatCount} ${reservation.seatCount == 1 ? 'Seat' : 'Seats'}',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: reservation.seatIds
                              .map((seatId) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8D6E63),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '#$seatId',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelDialog(context, reservation);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reservationDay = DateTime(date.year, date.month, date.day);

    if (reservationDay == today) {
      return 'Today, ${months[date.month - 1]} ${date.day}';
    } else if (reservationDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${months[date.month - 1]} ${date.day}';
    } else {
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _showCancelDialog(BuildContext context, ReservationModel reservation) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Reservation?',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel your reservation at ${reservation.restaurantName}?',
          style: GoogleFonts.tajawal(
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'No',
              style: GoogleFonts.cairo(
                color: Colors.grey[600],
              ),
            ),
          ),
          // ElevatedButton(
          //   onPressed: () async {
          //     try {
          //       await controller.cancelReservation(reservation.id);
          //       Get.back();
          //       Get.snackbar(
          //         'Reservation Cancelled',
          //         'Your reservation has been cancelled successfully',
          //         snackPosition: SnackPosition.BOTTOM,
          //         backgroundColor: Colors.red[600],
          //         colorText: Colors.white,
          //         duration: const Duration(seconds: 2),
          //       );
          //     } catch (e) {
          //       Get.back();
          //       Get.snackbar(
          //         'Error',
          //         'Failed to cancel reservation. Please try again.',
          //         snackPosition: SnackPosition.BOTTOM,
          //         backgroundColor: Colors.red[600],
          //         colorText: Colors.white,
          //         duration: const Duration(seconds: 2),
          //       );
          //     }
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.red[600],
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          //   child: Text(
          //     'Yes, Cancel',
          //     style: GoogleFonts.cairo(
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

