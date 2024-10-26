import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/home/screen/home_page.dart';
import 'package:pulsestrength/res/global_assets.dart';
import 'package:pulsestrength/res/global_variables.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final int duration = 500;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: duration * 6), () {
        Get.off(()=>const HomePage());
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pWhiteColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ZoomIn(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    ImageAssets.pLogo,
                    height: 150,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
