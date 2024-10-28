import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class SecondOnboardPage extends StatelessWidget {
  final double autoScale;

  const SecondOnboardPage({super.key, required this.autoScale});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pPurpleColor,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              ImageAssets.pCalculatorOBOne,
              width: Get.width,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  ImageAssets.pCalculatorLogo,
                  width: 200 * autoScale, // Responsive size
                  height: 200 * autoScale, // Responsive size
                ),
                SizedBox(height: 40 * autoScale), // Responsive padding
                ReusableText(
                  text: 'Track your \nfood!',
                  size: 32 * autoScale, // Responsive font size
                  color: AppColors.pWhiteColor, // Change to your desired color
                  align: TextAlign.center,
                  letterSpacing: 3,
                ),
                const Spacer(flex: 3)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
