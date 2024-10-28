import 'package:get/get.dart';
import 'package:pulsestrength/features/calculator/screen/side_calculator_page.dart';
import 'package:pulsestrength/features/onboard/calculator_onboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;


  Future<bool> checkOnboardingCompletion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingCompleted') ?? false;
  }

  // Method to set onboarding as completed
  Future<void> completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
  }

  Future<void> navigateToCalculator() async {
    bool isOnboardingCompleted = await checkOnboardingCompletion();
    if (isOnboardingCompleted) {
      Get.to(() => const MainCalculatorPage(), transition: Transition.leftToRight);
    } else {
      // Go to onboarding first if it's not completed
      Get.to(() => OnboardCalculator(
        onComplete: () async {
          await completeOnboarding(); // Mark as complete on skip or get started
          Get.off(() => const MainCalculatorPage(), transition: Transition.leftToRight);
        },
      ), transition: Transition.leftToRight);
    }
  }
}


