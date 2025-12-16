import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/category_model.dart';
import 'db_instance.dart';

class CategoryCrud {
  FirebaseFirestore get firestore => Get.find<CloudDb>().db;

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await firestore.collection('categories').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;
        return CategoryModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await firestore
          .collection('categories')
          .doc(category.id)
          .set(category.toJson());
      print('Category added: ${category.id}');
    } catch (e) {
      print('Error adding category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await firestore.collection('categories').doc(id).delete();
      print('Category deleted: $id');
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  Future<void> updateRestaurantCountByName(String name, int delta) async {
    try {
      final snapshot = await firestore
          .collection('categories')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        print('No category found with name: $name');
        return;
      }
      final docRef = snapshot.docs.first.reference;
      await docRef.update({
        'restaurantCount': FieldValue.increment(delta),
      });
      print('Updated restaurantCount for category $name by $delta');
    } catch (e) {
      print('Error updating restaurantCount for $name: $e');
    }
  }
}


