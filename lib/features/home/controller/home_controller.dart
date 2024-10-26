import 'package:get/get.dart';
import 'package:pulsestrength/features/calculator/screen/side_calculator_page.dart';


class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  void onProfileTap() {
    // Handle profile tap logic, like opening a profile page
  }

  void onSettingsTap() {
    // Handle settings tap logic, like opening settings
  }

  void navigateToCalculator() {
    Get.to(() => MainCalculatorPage());
  }
}
