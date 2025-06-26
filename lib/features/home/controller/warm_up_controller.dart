import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarmUpController extends GetxController {
  RxBool isWarmUpCompleted = false.obs;
  RxBool isWarmUpSkipped = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkWarmUpStatus();
  }

  Future<void> checkWarmUpStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    isWarmUpCompleted.value = prefs.getBool('warmup_completed_$dateKey') ?? false;
    isWarmUpSkipped.value = prefs.getBool('warmup_skipped_$dateKey') ?? false;
  }

  Future<void> markWarmUpComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    await prefs.setBool('warmup_completed_$dateKey', true);
    isWarmUpCompleted.value = true;
  }

  Future<void> markWarmUpSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    await prefs.setBool('warmup_skipped_$dateKey', true);
    isWarmUpSkipped.value = true;
  }

  bool shouldShowWarmUp() {
    return !isWarmUpCompleted.value && !isWarmUpSkipped.value;
  }
}