import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../db/category_crud.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  final CategoryCrud _categoryCrud = Get.find<CategoryCrud>();

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final TextEditingController nameController = TextEditingController();
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    selectedImage.value = null;
    super.onClose();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      categories.value = await _categoryCrud.getAllCategories();
    } catch (e) {
      print('Error loading categories: $e');
      categories.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Category name cannot be empty.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Optional: avoid duplicates by name
    if (categories.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      Get.snackbar(
        'Duplicate Category',
        'A category with this name already exists.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;

      String? imageBase64;
      if (selectedImage.value != null) {
        imageBase64 = await _convertImageToBase64(selectedImage.value!);
      }

      final category = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        imageBase64: imageBase64,
        restaurantCount: 0,
      );

      await _categoryCrud.addCategory(category);
      nameController.clear();
      selectedImage.value = null;
      await loadCategories();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add category: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Image handling
  Future<void> pickImage() async {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Get.back();
                await _pickImageFromSource(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () async {
                Get.back();
                await _pickImageFromSource(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
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

  void removeImage() {
    selectedImage.value = null;
  }

  Future<String?> _convertImageToBase64(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting category image to base64: $e');
      return null;
    }
  }

  Future<void> deleteCategory(CategoryModel category) async {
    try {
      await _categoryCrud.deleteCategory(category.id);
      categories.removeWhere((c) => c.id == category.id);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}


