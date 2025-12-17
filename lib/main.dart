import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_reservation_app/screens/my_reservations_screen.dart';
import 'package:restaurant_reservation_app/services/notification_service.dart';
import 'controllers/my_reservations_controller.dart';
import 'controllers/vendor_dashboard_controller.dart';
import 'controllers/add_restaurant_controller.dart';
import 'controllers/category_controller.dart';
import 'db/reservations_crud.dart';
import 'db/restaurant_crud.dart';
import 'db/category_crud.dart';
import 'db/db_instance.dart';
import 'firebase_options.dart';
import 'screens/vendor_dashboard.dart';
import 'screens/add_restaurant_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/manage_categories_screen.dart';
import 'controllers/notifications_controller.dart';

// Get FCM device token on app launch and store it in Firestore
final FirebaseMessaging _fcm = FirebaseMessaging.instance;

// Store the web token so it can be accessed from other parts of the app
String? webFcmToken;

Future<String?> getToken() async {
try {
// For web, configure the service worker path if needed
if (kIsWeb) {
await _fcm.setAutoInitEnabled(true);
}
String? token = await _fcm.getToken();
if (kIsWeb && token != null) {
webFcmToken = token; // Store web token
}
print("\n\n\n Device Token: $token \n\n\n");

// Save / update this device token in Firestore so backend can send to all devices
try {
await FirebaseFirestore.instance
.collection('deviceTokens')
.doc(token) // use token as document ID to avoid duplicates
.set({
'token': token,
'platform': defaultTargetPlatform.toString(),
'updatedAt': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
print("Device token saved to Firestore");
} catch (e) {
print("Error saving device token to Firestore: $e");
}

return token;
} catch (e) {
print("\n\n\n Error getting FCM token: $e \n\n\n");
// Don't crash the app if token retrieval fails
return null;
}
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
  
  // Show local notification when app is in background or terminated
  // This allows users to tap the notification and navigate to the app
  await NotificationService.showBackground(message);
}




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add error handling for Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  try {
    // Initialize Firebase
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e');
    print('Stack trace: $stackTrace');
    // Continue anyway - app might still work without Firebase in some cases
  }

  // Request notification permission for all platforms
  // This should be done early, before getting the token
  try {
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print("Notification permission status: ${settings.authorizationStatus}");

    // For web, small delay to ensure service worker is ready
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  } catch (e) {
    print("Error requesting notification permission: $e");
  }

  // Get token (with error handling) - defer to avoid blocking app startup
  getToken().then((token) {
    if (kIsWeb && token != null) {
      webFcmToken = token;
    }
  }).catchError((e) {
    print("Failed to get FCM token: $e");
  });

  try {
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );
  } catch (e) {
    print("Error setting up background message handler: $e");
  }

  // Init local notifications
  try {
    await NotificationService.init();
    print('NotificationService initialized successfully');
  } catch (e) {
    print("Error initializing NotificationService: $e");
  }

  // Listen to foreground messages
  try {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showForeground(message);
    });
  } catch (e) {
    print("Error setting up foreground message listener: $e");
  }

  // Handle notification when app is opened from background state
  try {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background via notification: ${message.messageId}');
      NotificationService.addMessageToFeed(message);
      // Navigate to notifications screen
      // Use a small delay to ensure GetX context is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          Get.toNamed('/notifications');
        } catch (e) {
          print('Error navigating to notifications from background: $e');
        }
      });
    });
  } catch (e) {
    print("Error setting up onMessageOpenedApp listener: $e");
  }

  // Capture initial message (processed later after deps are registered)
  RemoteMessage? initialMessage;
  try {
    initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state via notification: ${initialMessage.messageId}');
    }
  } catch (e) {
    print("Error checking initial message: $e");
  }

  // Initialize GetX dependencies
  try {
    Get.put(CloudDb(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(NotificationsController(), permanent: true);
    Get.put(ReservationsCrud(), permanent: true);
    Get.put(RestaurantCrud(), permanent: true);
    Get.put(CategoryCrud(), permanent: true);
    Get.put(VendorDashboardController(), permanent: true);
    print('All dependencies initialized successfully');
  } catch (e, stackTrace) {
    print('Error initializing dependencies: $e');
    print('Stack trace: $stackTrace');
    // Don't continue if dependencies fail
    rethrow;
  }

  runApp(const MyApp());

  // Now that dependencies are ready, process initial notification
  if (initialMessage != null) {
    try {
      NotificationService.addMessageToFeed(initialMessage);
    } catch (e) {
      print('Error adding initial notification to feed: $e');
    }
    Future.delayed(const Duration(milliseconds: 1000), () {
      try {
        Get.toNamed('/notifications');
      } catch (e) {
        print('Error navigating to notifications from terminated: $e');
      }
    });
  }
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
        GetPage(
          name: '/add-restaurant',
          page:()=> const AddRestaurantScreen(),
          binding: BindingsBuilder((){
            Get.lazyPut(()=>AddRestaurantController());
          }),
        ),
        GetPage(
          name: '/my-reservations',
          page:()=> const MyReservationsScreen(),
          binding: BindingsBuilder((){
            Get.lazyPut(()=>MyReservationsController());
          }),
        ),
        GetPage(
          name: '/manage-categories',
          page:()=> const ManageCategoriesScreen(),
          binding: BindingsBuilder((){
            Get.lazyPut(()=>CategoryController());
          }),
        ),
        GetPage(name: '/notifications', page: () => const NotificationsScreen()),
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