import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalculatorController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Observables
  var weight = 0.obs; // Changed to int
  var height = 0.obs; // Changed to int
  var age = 0.obs;
  var gender = ''.obs; // Non-editable gender field
  var bmi = 0.0.obs;
  var bmiCategory = ''.obs;
  var dropdownValue = 'Activity'.obs; // Default dropdown value
  var caloriesResultText = "Enter details to calculate calories.".obs;

  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController CalageController = TextEditingController();
  TextEditingController CalweightController = TextEditingController();
  TextEditingController CalheightController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchUserData(); // Fetch user data on initialization
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

          // Update the fields with the fetched data
          age.value = assessment['age'] ?? 0;
          weight.value = (assessment['weight'] ?? 0); // Stored as int
          height.value = (assessment['height'] ?? 0); // Stored as int
          gender.value = assessment['gender'] ?? 'Unknown';

          // Update the controllers with the fetched data
          ageController.text = age.value.toString();
          weightController.text = weight.value.toString();
          heightController.text = height.value.toString();
          CalageController.text = age.value.toString();
          CalweightController.text = weight.value.toString();
          CalheightController.text = height.value.toString();
        } else {
          Get.snackbar(
            "Error",
            "No assessment data found.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "User data not found in the database.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch user data: ${e.toString()}",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // Method to calculate BMI
  void calculateBMI() {
    if (areInputsValid()) {
      double heightInMeters = height.value / 100.0; // Convert int to meters
      bmi.value = weight.value / (heightInMeters * heightInMeters);
      bmiCategory.value = getBMIClassification(bmi.value, age.value, gender.value);
    } else {
      bmi.value = 0.0;
      bmiCategory.value = '';
    }
  }

  // Method to classify BMI
  String getBMIClassification(double bmi, int age, String gender) {
    if (age >= 18) {
      if (gender == "Male") {
        if (bmi < 18.5) return "Underweight";
        if (bmi < 24.9) return "Normal weight";
        if (bmi < 29.9) return "Overweight";
        return "Obese";
      } else {
        if (bmi < 18.0) return "Underweight";
        if (bmi < 24.0) return "Normal weight";
        if (bmi < 29.0) return "Overweight";
        return "Obese";
      }
    } else if (age >= 13 && age < 18) {
      if (bmi < 16.5) return "Underweight";
      if (bmi < 23.0) return "Normal weight";
      if (bmi < 27.0) return "Overweight";
      return "Obese";
    } else {
      if (bmi < 15.0) return "Underweight";
      if (bmi < 22.0) return "Normal weight";
      if (bmi < 26.0) return "Overweight";
      return "Obese";
    }
  }

  // Method to calculate calories
  double? calculateCalories() {
    if (dropdownValue.value == 'Activity' || !areInputsValid()) {
      caloriesResultText.value = "Enter details to calculate calories.";
      return null;
    }

    if (height.value > 0 && weight.value > 0 && age.value > 0) {
      double bmr;
      if (gender.value == "Male") {
        bmr = 88.362 + (13.397 * weight.value) + (4.799 * height.value) - (5.677 * age.value);
      } else {
        bmr = 447.593 + (9.247 * weight.value) + (3.098 * height.value) - (4.330 * age.value);
      }

      double calorieMultiplier = getCalorieMultiplier();
      double calories = bmr * calorieMultiplier;
      caloriesResultText.value = "Your daily calorie requirement: ${calories.toStringAsFixed(0)} kcal";
      return calories;
    }
    return null;
  }

  bool areInputsValid() {
    return weight.value > 0 && height.value > 0 && age.value > 0;
  }

  double getCalorieMultiplier() {
    switch (dropdownValue.value) {
      case 'Sedentary: little or no exercise':
        return 1.2;
      case 'Light: exercise 1-3 times/week':
        return 1.375;
      case 'Moderate: exercise 4-5 times/week':
        return 1.55;
      case 'Active: daily exercise or intense 3-4 times/week':
        return 1.725;
      case 'Very Active: intense exercise 6-7 times/week':
        return 1.9;
      case 'Extra Active: very intense exercise daily, or physical job':
        return 2.0;
      default:
        return 1.0;
    }
  }

  void clearBMIInputs() {
    height.value = 0;
    weight.value = 0;
    age.value = 0;
    bmi.value = 0.0;
    bmiCategory.value = '';
    ageController.clear();
    weightController.clear();
    heightController.clear();
  }

  void clearCaloriesInputs() {
    height.value = 0;
    weight.value = 0;
    age.value = 0;
    dropdownValue.value = 'Activity';
    caloriesResultText.value = "Enter details to calculate calories.";
    CalageController.clear();
    CalweightController.clear();
    CalheightController.clear();
  }
}
