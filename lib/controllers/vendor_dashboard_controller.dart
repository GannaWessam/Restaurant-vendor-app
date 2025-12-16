import 'package:get/get.dart';
import '../db/restaurant_crud.dart';
import '../db/category_crud.dart';
import '../models/restaurant_model.dart';
import '../models/category_model.dart';

class VendorDashboardController extends GetxController {
  final RestaurantCrud _restaurantCrud = Get.find<RestaurantCrud>();
  final CategoryCrud _categoryCrud = Get.find<CategoryCrud>();

  // Reactive state
  final RxList<RestaurantModel> restaurants = <RestaurantModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
    loadCategories();
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

  // Load all categories
  Future<void> loadCategories() async {
    try {
      final categoriesData = await _categoryCrud.getAllCategories();
      categories.value = categoriesData;
    } catch (e) {
      print('Error loading categories: $e');
      categories.value = [];
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

  // Refresh categories list
  Future<void> refreshCategories() async {
    await loadCategories();
  }
}
