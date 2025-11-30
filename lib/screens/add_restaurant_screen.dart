import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import '../controllers/add_restaurant_controller.dart';

class AddRestaurantScreen extends StatelessWidget {
  const AddRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddRestaurantController controller = Get.find<AddRestaurantController>();
  final _formKey = GlobalKey<FormState>();






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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add new restaurant',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Define the location, breakfast concept, tables and seats.\nYou can adjust details later from the restaurant profile.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant photo
                      const Text(
                        'Restaurant photo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: controller.pickImage,
                        child: Obx(() => Container(
                          width: double.infinity,
                          height: controller.selectedImage.value != null ? 200 : null,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: controller.selectedImage.value != null ? Colors.transparent : null,
                          ),
                          child: controller.selectedImage.value != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: kIsWeb
                                          ? FutureBuilder<Uint8List>(
                                              future: controller.selectedImage.value!.readAsBytes(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Image.memory(
                                                    snapshot.data!,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                  );
                                                }
                                                return const Center(
                                                  child: CircularProgressIndicator(),
                                                );
                                              },
                                            )
                                          : Image.file(
                                              File(controller.selectedImage.value!.path),
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        onPressed: controller.removeImage,
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.photo_library_outlined,
                                        size: 28,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Add a cover photo',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C2C2C),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Ideal: wide shot of your breakfast setup or storefront.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                  ],
                                ),
                        )),
                      ),
                      const SizedBox(height: 24),
                      // Location
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.locationController,
                              decoration: InputDecoration(
                                hintText: 'Add location',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              // Get current location logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2C2C2C),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Get current location',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Restaurant name
                      const Text(
                        'Restaurant name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controller.nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Hilton Hotel – Breakfast Lounge',
                          hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Breakfast category
                      const Text(
                        'Breakfast category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => DropdownMenu<String>(
                        initialSelection: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
                        hintText: 'Choose a breakfast cuisine',
                        width: MediaQuery.of(context).size.width - 40,
                        menuHeight: 300,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2C2C2C),
                        ),
                        inputDecorationTheme: InputDecorationTheme(
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 14,
                          ),
                        ),
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: 'American Breakfast',
                            label: 'American Breakfast',
                          ),
                          DropdownMenuEntry(
                            value: 'Continental Breakfast',
                            label: 'Continental Breakfast',
                          ),
                          DropdownMenuEntry(
                            value: 'English Breakfast',
                            label: 'English Breakfast',
                          ),
                          DropdownMenuEntry(
                            value: 'French Breakfast',
                            label: 'French Breakfast',
                          ),
                          DropdownMenuEntry(
                            value: 'Mediterranean Breakfast',
                            label: 'Mediterranean Breakfast',
                          ),
                          DropdownMenuEntry(
                            value: 'Middle Eastern Breakfast',
                            label: 'Middle Eastern Breakfast',
                          ),
                          DropdownMenuEntry(
                            value: 'Asian Breakfast',
                            label: 'Asian Breakfast',
                          ),
                          DropdownMenuEntry(
                            value: 'Buffet Style',
                            label: 'Buffet Style',
                          ),
                          DropdownMenuEntry(
                            value: 'Brunch',
                            label: 'Brunch',
                          ),
                          DropdownMenuEntry(
                            value: 'Healthy & Organic',
                            label: 'Healthy & Organic',
                          ),
                          DropdownMenuEntry(
                            value: 'Vegan & Vegetarian',
                            label: 'Vegan & Vegetarian',
                          ),
                          DropdownMenuEntry(
                            value: 'Coffee & Pastries',
                            label: 'Coffee & Pastries',
                          ),
                        ],
                        onSelected: (value) {
                          controller.selectedCategory.value = value ?? '';
                        },
                      )),
                      const SizedBox(height: 24),
                      // Number of tables
                      const Text(
                        'Number of tables',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controller.tablesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g. 3',
                          hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            controller.generateTables();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This value will be used to generate Table 1, Table 2... when this form is connected to your app logic.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tables & seats
                      const Text(
                        'Tables & seats',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => Column(
                        children: controller.tables.map((table) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F8F8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      table['name'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF2C2C2C),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: table['seats'],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Seats',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFAAAAAA),
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F8F8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      table['seats'] = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Add restaurant button
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        child: Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.addRestaurant,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Add restaurant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

