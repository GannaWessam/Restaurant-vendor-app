import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import '../db/restaurant_crud.dart';
import '../models/restaurant_model.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _tablesController = TextEditingController();
  String? _selectedCategory;
  final List<Map<String, dynamic>> _tables = [];
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final RestaurantCrud _restaurantCrud = Get.find<RestaurantCrud>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with 3 tables
    _tables.addAll([
      {'name': 'Table 1', 'seats': ''},
      {'name': 'Table 2', 'seats': ''},
      {'name': 'Table 3', 'seats': ''},
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _tablesController.dispose();
    super.dispose();
  }

  void _generateTables() {
    final numberOfTables = int.tryParse(_tablesController.text);
    if (numberOfTables != null && numberOfTables > 0) {
      setState(() {
        _tables.clear();
        for (int i = 1; i <= numberOfTables; i++) {
          _tables.add({'name': 'Table $i', 'seats': ''});
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadImageToFirebase(XFile image) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final String fileName = 'restaurants/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final Reference ref = storage.ref().child(fileName);
      
      UploadTask uploadTask;
      if (kIsWeb) {
        final Uint8List bytes = await image.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        uploadTask = ref.putFile(File(image.path));
      }
      
      // Add timeout to prevent hanging
      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Image upload timed out after 30 seconds');
        },
      );
      final String downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
      );
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addRestaurant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required fields
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a breakfast category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a restaurant name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected (non-blocking - continue even if it fails)
      String? imageUrl;
      if (_selectedImage != null) {
        try {
          print('Starting image upload...');
          imageUrl = await _uploadImageToFirebase(_selectedImage!);
          if (imageUrl == null) {
            print('Image upload failed, continuing without image');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image upload failed. Saving restaurant without image.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            print('Image uploaded successfully: $imageUrl');
          }
        } catch (e) {
          print('Image upload error: $e');
          // Continue without image
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload error: $e. Saving restaurant without image.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      // Format tables data
      final tablesInfo = _tables.map((table) => 
        '${table['name']}: ${table['seats']} seats'
      ).join(', ');

      // Create restaurant model
      print('Creating restaurant model...');
      final restaurant = RestaurantModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        distance: _locationController.text.trim().isEmpty 
            ? 'Unknown distance' 
            : _locationController.text.trim(),
        rating: 0.0, // Default rating
        tables: tablesInfo.isEmpty ? '${_tables.length} tables' : tablesInfo,
        imagePath: imageUrl,
        description: null,
        timeSlots: const [
          '7:00 AM',
          '8:00 AM',
          '9:00 AM',
          '10:00 AM',
          '11:00 AM',
        ],
      );

      // Add restaurant to Firestore with timeout
      print('Saving restaurant to Firestore...');
      await _restaurantCrud.addRestaurant(restaurant).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Firestore save timed out after 15 seconds');
        },
      );
      print('Restaurant saved successfully!');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant added successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding restaurant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: _selectedImage != null ? 200 : null,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _selectedImage != null ? Colors.transparent : null,
                          ),
                          child: _selectedImage != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: kIsWeb
                                          ? FutureBuilder<Uint8List>(
                                              future: _selectedImage!.readAsBytes(),
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
                                              File(_selectedImage!.path),
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedImage = null;
                                          });
                                        },
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
                        ),
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
                              controller: _locationController,
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
                        controller: _nameController,
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
                      DropdownMenu<String>(
                        initialSelection: _selectedCategory,
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
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
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
                        controller: _tablesController,
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
                            _generateTables();
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
                      ..._tables.map((table) {
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
        child: ElevatedButton(
          onPressed: _isLoading ? null : _addRestaurant,
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
          child: _isLoading
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

