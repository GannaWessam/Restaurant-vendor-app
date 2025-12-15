import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../models/restaurant_model.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Restaurant Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Image
                    if (restaurant.imageBase64 != null && restaurant.imageBase64!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 250,
                          width: double.infinity,
                          color: const Color(0xFFE8F5E9),
                          child: Image.memory(
                            base64Decode(restaurant.imageBase64!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          ),
                        ),
                      )
                    else
                      _buildPlaceholderImage(),
                    const SizedBox(height: 24),
                    // Restaurant Name
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category and Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            restaurant.distance,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          restaurant.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    if (restaurant.description != null && restaurant.description!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        restaurant.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    // Time Slots
                    const Text(
                      'Operating Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: restaurant.timeSlots.map((slot) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    // Tables Information
                    const Text(
                      'Tables & Seats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Text(
                        restaurant.tables,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    Color bgColor;
    Color iconColor;
    
    // Different colors for different restaurants
    if (restaurant.name.contains('Brioche')) {
      bgColor = const Color(0xFFDC143C); // Crimson red
      iconColor = Colors.white;
    } else if (restaurant.name.contains('Arabiata')) {
      bgColor = const Color(0xFF8B0000); // Dark red
      iconColor = Colors.white;
    } else {
      bgColor = const Color(0xFFE8F5E9); // Light green
      iconColor = const Color(0xFF4CAF50);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 250,
        width: double.infinity,
        color: bgColor,
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.restaurant,
                size: 80,
                color: iconColor.withOpacity(0.3),
              ),
            ),
            // Add brand-specific styling
            if (restaurant.name.contains('Brioche'))
              Center(
                child: Text(
                  'Brioche\nDorée',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'serif',
                    height: 1.0,
                  ),
                ),
              )
            else if (restaurant.name.contains('Arabiata'))
              Center(
                child: Text(
                  'a\narabiata',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'serif',
                    height: 0.9,
                    letterSpacing: -2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
