import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_reservation_app/screens/my_reservations_screen.dart';
import 'controllers/my_reservations_controller.dart';
import 'controllers/vendor_dashboard_controller.dart';
import 'controllers/add_restaurant_controller.dart';
import 'db/reservations_crud.dart';
import 'db/restaurant_crud.dart';
import 'db/db_instance.dart';
import 'firebase_options.dart';
import 'screens/vendor_dashboard.dart';
import 'screens/add_restaurant_screen.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize Firebase after running: flutterfire configure
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(CloudDb(), permanent: true);
  Get.put(ReservationsCrud(), permanent: true);
  Get.put(RestaurantCrud(), permanent: true);
  Get.put(VendorDashboardController(), permanent: true);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Restaurant Reservation',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: ()=> const VendorDashboard()),
        GetPage(name: '/add-restaurant',
            page:()=> const AddRestaurantScreen(),
            binding: BindingsBuilder((){
              Get.lazyPut(()=>AddRestaurantController());
            })),
        GetPage(name: '/my-reservations',
            page:()=> const MyReservationsScreen(),
            binding: BindingsBuilder((){
              Get.lazyPut(()=>MyReservationsController());
            }))
      ],

      // Apply custom theme with color palette
      theme: _buildTheme(),
    );
  }

  // Theme based on Beautiful Palette 2
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      
      // Color Palette
      primaryColor: const Color(0xFFB08968), // Medium brown
      scaffoldBackgroundColor: const Color(0xFFEDE0D4), // Lightest beige
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFB08968), // Medium brown
        secondary: Color(0xFF7F5539), // Dark brown
        tertiary: Color(0xFF9C6644), // Brown
        surface: Color(0xFFE6CCB2), // Light tan
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF7F5539), // Dark brown for text
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFB08968),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF7F5539),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF7F5539),
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF7F5539),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF9C6644),
          fontSize: 14,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDB892)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDB892)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB08968), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9C6644)),
        prefixIconColor: Color(0xFF9C6644),
        suffixIconColor: Color(0xFF9C6644),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F5539), // Dark brown
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF7F5539),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}