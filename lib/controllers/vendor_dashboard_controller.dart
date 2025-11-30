import 'package:get/get.dart';
import '../db/restaurant_crud.dart';
import '../models/restaurant_model.dart';

class VendorDashboardController extends GetxController {
  final RestaurantCrud _restaurantCrud = Get.find<RestaurantCrud>();

  // Reactive state
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
  }

  // Load all restaurants
  Future<void> loadRestaurants() async {
    try {
      isLoading.value = true;
      final restaurantsData = await _restaurantCrud.getAllRestaurants();
      restaurants.value = restaurantsData;
    } catch (e) {
      print('Error loading restaurants: $e');
      restaurants.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Get unique categories from restaurants
  List<String> getUniqueCategories() {
    return restaurants.map((r) => r.category).toSet().toList();
  }

  // Refresh restaurants list
  Future<void> refreshRestaurants() async {
    await loadRestaurants();
  }
}
