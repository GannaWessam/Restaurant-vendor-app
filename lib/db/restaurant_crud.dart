import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../models/restaurant_model.dart';
import 'db_instance.dart';

class RestaurantCrud {
  // final FirebaseFirestore firestore = Get.find<CloudDb>().db;
  // Lazy initialization - only access Firestore when firestore is first accessed
  FirebaseFirestore get firestore => Get.find<CloudDb>().db;

  Future<void> addRestaurant(RestaurantModel restaurant) async { //vendor
    try {
      await firestore.collection('restaurants').doc(restaurant.id).set(restaurant.toJson());
      print('Restaurant added: ${restaurant.id}');
    } catch (e) {
      print(e);
    }
  }
  Future<List<RestaurantModel>> getAllRestaurants() async { //vendor
    try {
      final restaurantsSnapshot = await firestore.collection('restaurants').get();
      return restaurantsSnapshot.docs.map((restaurant)=>
          RestaurantModel.fromJson(restaurant.data())).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }


  // Future<List<RestaurantModel>> getRestaurantsByCategory(String category) async { //user
  //     try {
  //       final restaurantsSnapshot =
  //         await firestore.collection('restaurants').where('category', isEqualTo: category).get();
  //
  //
  //       return restaurantsSnapshot.docs.map((doc) {
  //         final data = doc.data();
  //         // Include document ID in the data
  //         data['id'] = doc.id;
  //         print('Restaurant data: $data');
  //
  //         try {
  //           return RestaurantModel.fromJson(data);
  //         } catch (e) {
  //           print('Error parsing restaurant ${doc.id}: $e');
  //           print('Data: $data');
  //           // Return null for invalid documents, filter them out
  //           return null;
  //         }
  //       }).where((restaurant) => restaurant != null).cast<RestaurantModel>().toList();
  //     } catch (e) {
  //       print('Error getting restaurants by category: $e');
  //       return [];
  //     }
  //   }

}