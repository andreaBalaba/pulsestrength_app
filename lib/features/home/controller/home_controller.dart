import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pulsestrength/features/calculator/screen/side_calculator_page.dart';
import 'package:pulsestrength/features/onboard/calculator_onboard_page.dart';

class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;
  Rxn<String> username = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        username.value = null; // Clear username if no user is logged in
        return;
      }

      String userId = user.uid;
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId/username');
      DatabaseEvent event = await userRef.once();

      if (event.snapshot.exists) {
        username.value = event.snapshot.value.toString();
      } else {
        username.value = 'Unknown User'; // Default if username doesn't exist
      }
    } catch (e) {
      username.value = 'Error fetching username';
      print('Error fetching username: $e');
    }
  }

  void resetUsername() {
    username.value = null; // Clear the username explicitly
  }

  Future<bool> checkOnboardingCompletion() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) return false;

      String userId = user.uid;
      DatabaseReference onboardRef = FirebaseDatabase.instance.ref('users/$userId/isCalculatorOnboarded');
      DatabaseEvent event = await onboardRef.once();

      if (event.snapshot.exists) {
        return event.snapshot.value as bool; // Return the onboarding status
      } else {
        return false; // Default to not onboarded if the flag doesn't exist
      }
    } catch (e) {
      print('Error checking onboarding completion: $e');
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      String userId = user.uid;
      DatabaseReference onboardRef = FirebaseDatabase.instance.ref('users/$userId');
      await onboardRef.update({"isCalculatorOnboarded": true}); // Set onboarding status to true
    } catch (e) {
      print('Error completing onboarding: $e');
    }
  }

  Future<void> navigateToCalculator() async {
    bool isOnboardingCompleted = await checkOnboardingCompletion();
    if (isOnboardingCompleted) {
      Get.to(() => const MainCalculatorPage(), transition: Transition.leftToRight);
    } else {
      Get.to(() => OnboardCalculator(
        onComplete: () async {
          await completeOnboarding(); // Mark as complete on skip or get started
          Get.off(() => const MainCalculatorPage(), transition: Transition.leftToRight);
        },
      ), transition: Transition.leftToRight);
    }
  }
}
