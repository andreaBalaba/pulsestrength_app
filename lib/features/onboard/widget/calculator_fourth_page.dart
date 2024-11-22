import 'package:flutter/material.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class FourthOnboardPage extends StatelessWidget {
  final double autoScale;
  final VoidCallback onComplete;

  const FourthOnboardPage({super.key, required this.autoScale, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pPurpleColor,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              ImageAssets.pCalculatorOBThree,
              width: 250 * autoScale,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  ImageAssets.pCalculatorLogo,
                  width: 150 * autoScale,
                  height: 150 * autoScale,
                ),
                SizedBox(height: 40 * autoScale),
                ReusableText(
                  text: 'Know How Many\n Calories You\n Burn Every Day',
                  size: 32 * autoScale,
                  color: AppColors.pWhiteColor,
                  align: TextAlign.center,
                  letterSpacing: 3,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.pPurpleColor,
                      backgroundColor: Colors.white, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    ),
                    child: const ReusableText(
                      text: 'Get Started',
                      size: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pPurpleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
