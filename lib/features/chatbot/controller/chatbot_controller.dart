import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBotController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Observables
  var gender = ''.obs;
  var age = 0.obs;
  var height = 0.0.obs;
  var weight = 0.0.obs;


  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  // Fetch user data from Firebase
  Future<void> fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is currently signed in.");
      }

      // Retrieve data from Firebase
      final DataSnapshot snapshot = await _databaseRef.child("users").child(user.uid).get();

      if (snapshot.exists) {
        final Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);

        // Extract assessment data if it exists
        if (userData.containsKey('assessment')) {
          final assessment = Map<String, dynamic>.from(userData['assessment']);

          // Update the observables with the fetched data
          gender.value = assessment['gender'] ?? 'Male';
          age.value = assessment['age'] ?? 0;
          height.value = assessment['height']?.toDouble() ?? 0.0;
          weight.value = assessment['weight']?.toDouble() ?? 0.0;
        } else {
          // Handle the case when assessment data is not available
          Get.snackbar(
            "Error",
            "No assessment data found.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        // Handle the case when user data is not found in the database
        Get.snackbar(
          "Error",
          "User data not found in the database.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Handle any errors that occur during data retrieval
      Get.snackbar(
        "Error",
        "Failed to fetch user data: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

}