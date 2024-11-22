import 'package:flutter/material.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class FirstOnboardPage extends StatelessWidget {
  final double autoScale;

  const FirstOnboardPage({super.key, required this.autoScale});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pPurpleColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Spacer(flex: 1),
          Image.asset(
            ImageAssets.pCalculatorLogo,
            width: 200 * autoScale,
            height: 200 * autoScale,
          ),
          SizedBox(height: 40 * autoScale),
          ReusableText(
            text: 'Calculate\nit right!',
            size: 32 * autoScale,
            color: AppColors.pWhiteColor,
            align: TextAlign.center,
            letterSpacing: 3,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
