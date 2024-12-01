import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pulsestrength/features/assessment/controller/assessment_controller.dart';
import 'package:pulsestrength/features/authentication/controller/login_controller.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/features/authentication/screen/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final AssessmentController assessmentController = Get.put(AssessmentController());


  final RxBool isNotificationEnabled = false.obs;
  final RxBool isWarmUpEnabled = false.obs;
  final RxBool isStretchingEnabled = false.obs;
  final RxString selectedGender = 'Female'.obs;

  // User data
  final RxInt age = 0.obs;
  final RxInt weight = 0.obs;
  final RxInt height = 0.obs;

  // Fetch user data
  Future<void> fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is currently signed in.");
      }

      final DataSnapshot snapshot = await _databaseRef.child("users").child(user.uid).get();

      if (snapshot.exists) {
        final Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);

        if (userData.containsKey('assessment')) {
          final assessment = Map<String, dynamic>.from(userData['assessment']);
          age.value = assessment['age'] ?? 0;
          weight.value = (assessment['weight'] ?? 0).toInt();
          height.value = (assessment['height'] ?? 0).toInt();
          selectedGender.value = assessment['gender'] ?? 'Female';
        } else {
          Get.snackbar("Error", "No assessment data found.");
        }
      } else {
        Get.snackbar("Error", "User data not found in the database.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user data: ${e.toString()}");
    }
  }

  Future<void> editInformation() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user is currently signed in.");
      }

      final userId = user.uid;
      final userRef = _databaseRef.child("users").child(userId).child("assessment");

      // Fetch current data to avoid overwriting other fields
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        final Map<String, dynamic> currentData = Map<String, dynamic>.from(snapshot.value as Map);

        currentData['gender'] = selectedGender.value;
        currentData['age'] = age.value;
        currentData['weight'] = weight.value;
        currentData['height'] = height.value;

        await userRef.set(currentData);

      } else {
        Get.snackbar(
          'Error',
          'No existing assessment data found to update.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save assessment data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    }
  }


  // Toggle methods for each setting
  void toggleNotification(bool value) {
    isNotificationEnabled.value = value;
    Get.snackbar(
      'Settings',
      'Notifications ${value ? 'enabled' : 'disabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.pMGreyColor,
    );
  }

  void toggleWarmUp(bool value) {
    isWarmUpEnabled.value = value;
    Get.snackbar(
      'Settings',
      'Warm up ${value ? 'enabled' : 'disabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.pMGreyColor,
    );
  }

  void toggleStretching(bool value) {
    isStretchingEnabled.value = value;
    Get.snackbar(
      'Settings',
      'Stretching ${value ? 'enabled' : 'disabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.pMGreyColor,
    );
  }

  // Method to select gender
  void selectGender(String gender) {
    selectedGender.value = gender;
    editInformation();
    Get.snackbar(
      'Settings',
      'Gender set to $gender',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.pMGreyColor,
    );
  }

  Future<void> signOut() async {
    try {
      // Firebase Sign-Out
      await _auth.signOut();

      // Google Sign-Out
      await _googleSignIn.signOut().catchError((error) {
        print("Google sign-out error: $error");
        return null;
      });

      // Clear SharedPreferences (Persistent Data)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      LoginController? loginController;
      try {
        loginController = Get.find<LoginController>();
        loginController.clearForm();
      } catch (e) {
        print("LoginController not found: $e");
      }

      Get.offAll(() => const LogInPage());
    } catch (e) {
      Get.snackbar(
        "Logout Failed",
        "Error: ${e.toString()}",
        colorText: AppColors.pWhiteColor,
        backgroundColor: Colors.redAccent,
      );
    }
  }
}
