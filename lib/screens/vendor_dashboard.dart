import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/restaurant_card.dart';
import '../controllers/vendor_dashboard_controller.dart';

class VendorDashboard extends StatelessWidget {
  const VendorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final VendorDashboardController controller = Get.find<VendorDashboardController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      endDrawer: _buildDrawer(context),
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          return SafeArea(
            child: Stack( //Stack = عناصر فوق بعض
              children: [
                // Main content
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                      children: [
                        // Header section
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Profile avatar
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'FV',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Actions: notifications + menu
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.toNamed('/notifications');
                                        },
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.notifications_none,
                                            color: Theme.of(context).colorScheme.secondary,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Scaffold.of(scaffoldContext).openEndDrawer();
                                        },
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.menu,
                                            color: Theme.of(context).colorScheme.secondary,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          const SizedBox(height: 6),
                          // Vendor name
                          // const Text(
                          //   'Futurah Vendor',
                          //   style: TextStyle(
                          //     fontSize: 15,
                          //     fontWeight: FontWeight.w600,
                          //     color: Color(0xFF2C2C2C),
                          //   ),
                          // ),
                          Text(
                            'Easy way to control your restaurants ',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                    // Scrollable content: Service card + Restaurant cards
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 100,
                          
                        ),
                        children: [
                          // Service info card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 220, 187, 151),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TODAY',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Morning service at a glance',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2C2C2C),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Track every breakfast restaurant you manage, update concepts and keep seating capacity in sync before the rush starts.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF666666),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Obx(() => Row(
                                  children: [
                                    _buildStatChip('Restaurants', '${controller.restaurants.length}'),
                                    const SizedBox(width: 6),
                                    _buildStatChip('Breakfast cuisines', '${controller.categories.length}'),
                                  ],
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Section title
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your restaurants',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                              Text(
                                'Tap a card to manage tables',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Restaurant cards
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (controller.restaurants.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.restaurant_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No restaurants yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap the + button to add your first restaurant',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                children: controller.restaurants.map((restaurant) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: RestaurantCard(restaurant: restaurant),
                                  );
                                }).toList(),
                              );
                            }
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
            // Floating action button
            Positioned(
              bottom: 40,
              right: 30,
              child: GestureDetector(
                onTap: () async {
                  await Get.toNamed('/add-restaurant');
                  // Refresh restaurants list when returning from add screen
                  controller.refreshRestaurants();
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'FV',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Futurah Vendor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'vendor@futurah.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ListTile(
                  //   leading: Icon(
                  //     Icons.restaurant_outlined,
                  //     color: Theme.of(context).colorScheme.secondary,
                  //   ),
                  //   title: Text(
                  //     'My Restaurants',
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.onSurface,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  //   onTap: () {
                  //     Get.back();
                  //     // Navigate to restaurants screen if needed
                  //     // Get.toNamed('/restaurants');
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(
                      Icons.category_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      'Manage categories',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      Get.back();
                      await Get.toNamed('/manage-categories');
                      // Refresh categories list when returning from manage categories screen
                      Get.find<VendorDashboardController>().refreshCategories();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.calendar_today_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      'Reservations',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Get.toNamed('/my-reservations');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

