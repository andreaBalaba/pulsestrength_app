import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/calculator/controller/side_calculator_controller.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class BmiWidget extends StatelessWidget {
  const BmiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CalculatorController calculatorController =
    Get.put(CalculatorController());

    // Ensure BMI calculation is triggered after fetching user data
    calculatorController.fetchUserData().then((_) {
      calculatorController.calculateBMI(); // Calculate BMI after defaults are set
    });

    double screenWidth = Get.width;
    double autoScale = screenWidth / 400;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.3,
                    child: TextField(
                      controller: calculatorController.ageController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        calculatorController.age.value =
                            int.tryParse(value) ?? 0;
                        calculatorController.calculateBMI();
                      },
                      decoration: InputDecoration(
                        hintText: 'Age',
                        filled: true,
                        fillColor: AppColors.pWhiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ReusableText(
                              text: 'Gender:',
                              fontWeight: FontWeight.w500,
                              size: 16 * autoScale),
                          const SizedBox(width: 8),
                          Obx(() => ReusableText(
                            text: calculatorController.gender.value,
                            fontWeight: FontWeight.w500,
                            size: 16 * autoScale,
                          )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.3,
                    child: TextField(
                      controller: calculatorController.weightController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        calculatorController.weight.value =
                            int.tryParse(value) ?? 0; // Updated to parse as int
                        calculatorController.calculateBMI();
                      },
                      decoration: InputDecoration(
                        hintText: 'Weight',
                        filled: true,
                        fillColor: AppColors.pWhiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ReusableText(text: "kg", size: 16 * autoScale),
                ],
              ),
            ),
            const SizedBox(height: 40.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth * 0.3,
                    child: TextField(
                      controller: calculatorController.heightController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        calculatorController.height.value =
                            int.tryParse(value) ?? 0; // Updated to parse as int
                        calculatorController.calculateBMI();
                      },
                      decoration: InputDecoration(
                        hintText: 'Height',
                        filled: true,
                        fillColor: AppColors.pWhiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ReusableText(text: "cm", size: 16 * autoScale),
                ],
              ),
            ),
            const SizedBox(height: 40.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: screenWidth * 0.9,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.pPurpleColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ReusableText(
                        text: "Result:",
                        fontWeight: FontWeight.bold,
                        size: 24 * autoScale,
                        color: AppColors.pWhiteColor,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          calculatorController.clearBMIInputs();
                          calculatorController.ageController.clear();
                          calculatorController.weightController.clear();
                          calculatorController.heightController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pBGWhiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: ReusableText(
                          text: "Clear",
                          color: AppColors.pPurpleColor,
                          fontWeight: FontWeight.bold,
                          size: 14 * autoScale,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Obx(() {
                      String resultText = calculatorController
                          .bmiCategory.value.isNotEmpty
                          ? "Your BMI: ${calculatorController.bmi.value.toStringAsFixed(1)}\nClassification: ${calculatorController.bmiCategory.value}"
                          : "Enter details to calculate BMI.";
                      return ReusableText(
                        text: resultText,
                        color: AppColors.pWhiteColor,
                        fontWeight: FontWeight.w600,
                        size: 18 * autoScale,
                        align: TextAlign.center,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
