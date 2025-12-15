import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../models/restaurant_model.dart';
import '../screens/restaurant_detail_screen.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantCard({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => RestaurantDetailScreen(restaurant: restaurant));
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          if (restaurant.imageBase64 != null && restaurant.imageBase64!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                height: 140,
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
          // Content section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant name
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                // Location and description
                if (restaurant.description != null && restaurant.description!.isNotEmpty) ...[
                  Text(
                    restaurant.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  '${restaurant.distance} • ${restaurant.category}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 12),
                // Opening time
                Text(
                  restaurant.timeSlots.isNotEmpty 
                      ? 'Opens ${restaurant.timeSlots.first}' 
                      : 'Closed',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
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
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        height: 140,
        width: double.infinity,
        color: bgColor,
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.restaurant,
                size: 50,
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
                    fontSize: 40,
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
                    fontSize: 50,
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

