import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/authentication/screen/login_page.dart';
import 'package:pulsestrength/features/home/screen/home_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final String? lastPage = prefs.getString('lastPage');

      if (isLoggedIn) {
        // Navigate to lastPage if it's HomePage, otherwise default to HomePage
        if (lastPage == 'HomePage') {
          Get.off(() => const HomePage());
        } else {
          Get.off(() => const HomePage()); // Default to HomePage for logged-in users
        }
      } else {
        Get.off(() => const LogInPage());
      }
    } catch (e) {
      print("Error navigating based on status: $e");
      Get.off(() => const LogInPage());
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
