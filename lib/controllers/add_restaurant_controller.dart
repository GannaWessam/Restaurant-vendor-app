import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../db/restaurant_crud.dart';
import '../models/restaurant_model.dart';

class AddRestaurantController extends GetxController {
  final RestaurantCrud _restaurantCrud = Get.find<RestaurantCrud>();

  // Form data
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final tablesController = TextEditingController();

  // Reactive state
  final RxString selectedCategory = ''.obs;
  final RxList<Map<String, dynamic>> tables = <Map<String, dynamic>>[].obs;
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with 3 tables
    tables.addAll([
      {'name': 'Table 1', 'seats': ''},
      {'name': 'Table 2', 'seats': ''},
      {'name': 'Table 3', 'seats': ''},
    ]);
  }

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    tablesController.dispose();
    super.onClose();
  }

  // Generate tables based on number input
  void generateTables() {
    final numberOfTables = int.tryParse(tablesController.text);
    if (numberOfTables != null && numberOfTables > 0) {
      tables.clear();
      for (int i = 1; i <= numberOfTables; i++) {
        tables.add({'name': 'Table $i', 'seats': ''});
      }
    }
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error picking image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Remove selected image
  void removeImage() {
    selectedImage.value = null;
  }

  // Convert image to base64
  Future<String?> _convertImageToBase64(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  // Add restaurant
  Future<void> addRestaurant() async {
    // Validate required fields
    if (selectedCategory.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a breakfast category',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a restaurant name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Convert image to base64 if selected
      String? imageBase64;
      if (selectedImage.value != null) {
        try {
          print('Converting image to base64...');
          imageBase64 = await _convertImageToBase64(selectedImage.value!);
          if (imageBase64 == null) {
            Get.snackbar(
              'Warning',
              'Image processing failed. Saving restaurant without image.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          } else {
            print('Image converted to base64 successfully');
          }
        } catch (e) {
          print('Image processing error: $e');
          Get.snackbar(
            'Warning',
            'Image processing error: $e. Saving restaurant without image.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }

      // Format tables data
      final tablesInfo = tables.map((table) =>
        '${table['name']}: ${table['seats']} seats'
      ).join(', ');

      // Create restaurant model
      print('Creating restaurant model...');
      final restaurant = RestaurantModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        category: selectedCategory.value,
        distance: locationController.text.trim().isEmpty
            ? 'Unknown distance'
            : locationController.text.trim(),
        rating: 0.0, // Default rating
        tables: tablesInfo.isEmpty ? '${tables.length} tables' : tablesInfo,
        imageBase64: imageBase64,
        description: null,
        timeSlots: const [
          '7:00 AM',
          '8:00 AM',
          '9:00 AM',
          '10:00 AM',
          '11:00 AM',
        ],
      );

      // Add restaurant to Firestore
      print('Saving restaurant to Firestore...');
      await _restaurantCrud.addRestaurant(restaurant).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Firestore save timed out after 15 seconds');
        },
      );

      print('Restaurant saved successfully!');

      // Clear form
      _clearForm();

      // Navigate back first, then show success message
      Get.back();
      
      // Show success message
      Get.snackbar(
        'Success',
        'Restaurant added successfully!',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Refresh restaurants list in dashboard (will be handled by the dashboard when it receives focus)

    } catch (e) {
      print('Error adding restaurant: $e');
      
      // Show failure message and stay on the same page
      Get.snackbar(
        'Failed',
        'Failed to add restaurant. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form data
  void _clearForm() {
    nameController.clear();
    locationController.clear();
    tablesController.clear();
    selectedCategory.value = '';
    tables.assignAll([
      {'name': 'Table 1', 'seats': ''},
      {'name': 'Table 2', 'seats': ''},
      {'name': 'Table 3', 'seats': ''},
    ]);
    selectedImage.value = null;
  }
}
