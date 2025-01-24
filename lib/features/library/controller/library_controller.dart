import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pulsestrength/model/exercise_model.dart';

class LibraryController extends GetxController {
  final databaseRef = FirebaseDatabase.instance.ref(); // Firebase reference
  var equipmentList = <Equipment>[].obs; // List of all equipment
  var filteredEquipmentList = <Equipment>[].obs; // Filtered list for search
  var savedEquipmentList = <Equipment>[].obs; // List of saved equipment
  final ScrollController scrollController = ScrollController();
  var searchQuery = ''.obs;
  

   @override
  void onInit() {
    super.onInit();
    loadEquipmentData();
    loadSavedEquipment(); // Load saved equipment on initialization
    debounce(searchQuery, (_) => searchEquipment(searchQuery.value), time: const Duration(milliseconds: 300));
  }

  // Load equipment data from JSON file
  Future<void> loadEquipmentData() async {
    final jsonString = await rootBundle.loadString('lib/api/Gym-equipments-Datas.json');
    final jsonData = json.decode(jsonString);
    final List<dynamic> equipmentData = jsonData['equipment'];
    equipmentList.value = equipmentData.map((item) => Equipment.fromJson(item)).toList();
    filteredEquipmentList.value = equipmentList;
  }



  Future<void> loadSavedEquipment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final snapshot = await databaseRef.child('users/$userId/savedEquipment').get();
      if (snapshot.exists) {
        try {
          final Map<dynamic, dynamic> rawData = snapshot.value as Map<dynamic, dynamic>;
          savedEquipmentList.value = rawData.values.map((item) {
            // Convert Map<dynamic, dynamic> to Map<String, dynamic>
            final Map<String, dynamic> stringMap = {};
            (item as Map<dynamic, dynamic>).forEach((key, value) {
              stringMap[key.toString()] = value;
            });
            return Equipment.fromJson(stringMap);
          }).toList();
        } catch (e) {
          print('Error loading saved equipment: $e');
          savedEquipmentList.value = [];
        }
      }
    } else {
      print("No user is logged in");
    }
  }

  // Save equipment to Firebase
  Future<void> saveEquipment(Equipment equipment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final equipmentId = equipment.name;
      final equipmentRef = databaseRef.child('users/$userId/savedEquipment/$equipmentId');
      
      final snapshot = await equipmentRef.get();
      if (snapshot.exists) {
        await equipmentRef.remove();
        savedEquipmentList.removeWhere((e) => e.name == equipment.name);
        
        Get.snackbar(
          'Equipment Unsaved',
          '${equipment.name} has been removed from your saved equipment.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
        );
      } else {
        await equipmentRef.set(equipment.toJson());
        savedEquipmentList.add(equipment);
        
        Get.snackbar(
          'Equipment Saved',
          '${equipment.name} has been added to your saved equipment.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(20),
        );
      }
    } else {
      // Handle case when user is not logged in
      print("No user is logged in");
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Search equipment
  void searchEquipment(String query) {
    if (query.isEmpty) {
      filteredEquipmentList.value = equipmentList;
    } else {
      filteredEquipmentList.value = equipmentList
          .where((equipment) =>
              equipment.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
