import 'package:flutter/material.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class ThirdOnboardPage extends StatelessWidget {
  final double autoScale;

  const ThirdOnboardPage({super.key, required this.autoScale});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pPurpleColor,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              ImageAssets.pCalculatorOBTwo, // Update with the correct asset path
              height: 450 * autoScale, // Adjust height as needed
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * autoScale), // Add some padding to the left
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
              children: [
                Image.asset(
                  ImageAssets.pCalculatorLogo,
                  width: 150 * autoScale, // Responsive size
                  height: 150 * autoScale, // Responsive size
                ),
                SizedBox(height: 30 * autoScale), // Responsive padding
                ReusableText(
                  text: 'Know your\n body!',
                  size: 32 * autoScale, // Responsive font size
                  color: AppColors.pWhiteColor, // Desired color
                  align: TextAlign.center, // Align text to the left
                  letterSpacing: 3,
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
