import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/assessment/screen/get_started_page.dart';
import 'package:pulsestrength/features/authentication/screen/login_page.dart';
import 'package:pulsestrength/features/home/screen/home_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final int duration = 500;

  @override
  void initState() {
    super.initState();
    _navigateBasedOnStatus();
  }

  Future<void> _navigateBasedOnStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        // If the user is logged in, check if they are signed in via Google or Email/Password
        final User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Check the user's data collection status in Realtime Database
          final DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child("users")
              .child(currentUser.uid);
          final DataSnapshot snapshot = await userRef.get();

          if (snapshot.exists) {
            final bool isDataCollected = snapshot.child("isDataCollected").value as bool? ?? false;

            // If data is collected, navigate to HomePage; otherwise, navigate to GetStarted page
            if (isDataCollected) {
              Get.offAll(() => const HomePage());
            } else {
              Get.offAll(() => const GetStarted()); // Redirect to Get Started page
            }
          } else {
            // If the user doesn't have data in the database, navigate to GetStartedPage
            Get.offAll(() => const GetStarted());
          }
        } else {
          // If no current user is logged in (Google or Email/Password), proceed to LogInPage
          Get.offAll(() => const LogInPage());
        }
      } else {
        // If the user is not logged in, navigate to LogInPage
        Get.offAll(() => const LogInPage());
      }
    } catch (e) {
      print("Error navigating based on status: $e");
      // In case of an error, fall back to the LogInPage
      Get.offAll(() => const LogInPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pWhiteColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ZoomIn(
              duration: Duration(milliseconds: duration),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    ImageAssets.pLogo,
                    height: 150,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
