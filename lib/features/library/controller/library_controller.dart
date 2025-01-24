import 'dart:convert';

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

  // Load saved equipment from Firebase
  Future<void> loadSavedEquipment() async {
    final userId = 'your-user-id'; // Replace with actual user ID
    final snapshot = await databaseRef.child('users/$userId/savedEquipment').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      savedEquipmentList.value = data.values
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  // Save equipment to Firebase
  Future<void> saveEquipment(Equipment equipment) async {
    final userId = 'your-user-id'; // Replace with actual user ID
    final equipmentMap = equipment.toJson();

    await databaseRef
        .child('users/$userId/savedEquipment')
        .push()
        .set(equipmentMap);

    savedEquipmentList.add(equipment); // Update the saved list locally
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
