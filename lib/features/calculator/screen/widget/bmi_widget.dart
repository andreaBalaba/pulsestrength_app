import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/calculator/controller/side_calculator_controller.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class BmiWidget extends StatelessWidget {
  const BmiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final CalculatorController calculatorController = Get.put(CalculatorController());
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
                      controller: calculatorController.ageController, // Use the controller from the CalculatorController
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        calculatorController.age.value = int.tryParse(value) ?? 0;
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
                          Obx(() => Radio<String>(
                            value: 'Male',
                            groupValue: calculatorController.gender.value,
                            onChanged: (String? value) {
                              calculatorController.gender.value = value ?? "Male";
                              calculatorController.calculateBMI();
                            },
                          )),
                          ReusableText(text: 'Male', fontWeight: FontWeight.w500, size: 16 * autoScale),
                        ],
                      ),
                      Row(
                        children: [
                          Obx(() => Radio<String>(
                            value: 'Female',
                            groupValue: calculatorController.gender.value,
                            onChanged: (String? value) {
                              calculatorController.gender.value = value ?? "Male";
                              calculatorController.calculateBMI();
                            },
                          )),
                          ReusableText(text: 'Female', fontWeight: FontWeight.w500, size: 16 * autoScale),
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
                      controller: calculatorController.weightController, // Use the controller from the CalculatorController
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        calculatorController.weight.value = double.tryParse(value) ?? 0.0;
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
                      controller: calculatorController.heightController, // Use the controller from the CalculatorController
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        calculatorController.height.value = double.tryParse(value) ?? 0.0;
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
                          // Clear inputs in the controller
                          calculatorController.clearBMIInputs();
                          // Also clear the TextEditingControllers
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
                      String resultText = calculatorController.bmiCategory.value.isNotEmpty
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
