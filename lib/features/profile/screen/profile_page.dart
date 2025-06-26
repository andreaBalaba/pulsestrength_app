import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/home/controller/home_controller.dart';
import 'package:pulsestrength/features/profile/screen/widget/equip_and_workout_card_widget.dart';
import 'package:pulsestrength/features/profile/screen/widget/username_widget.dart';
import 'package:pulsestrength/features/profile/screen/widget/weekly_progress_card_widget.dart';
import 'package:pulsestrength/features/progress/screen/widget/workout_week_progress_bar_widget.dart';
import 'package:pulsestrength/features/settings/screen/setting_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final HomeController homeController = Get.put(HomeController());
  final double autoScale = Get.width / 360;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.pBGWhiteColor,
        surfaceTintColor: AppColors.pNoColor,
        actions: [
          IconButton(
            icon: Image.asset(
              IconAssets.pSettingIcon,
              height: 30 * autoScale,
            ),
            onPressed: () {
              Get.to(() => const SettingsPage(), transition: Transition.rightToLeft);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * autoScale, vertical: 12 * autoScale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UserHeader(),
              const UserCards(),
              SizedBox(height: 12 * autoScale),
              WeeklyProgressCard(),
              SizedBox(height: 8 * autoScale),
              StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref('users/${FirebaseAuth.instance.currentUser!.uid}/Weekly')
                    .onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Loading'));
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  dynamic data = snapshot.data!.snapshot.value;

                  // Calculate sums for each day of the week
                  int sum1 = data['1']['mins'] ?? 0;
                  int sum2 = data['2']['mins'] ?? 0;
                  int sum3 = data['3']['mins'] ?? 0;
                  int sum4 = data['4']['mins'] ?? 0;
                  int sum5 = data['5']['mins'] ?? 0;
                  int sum6 = data['6']['mins'] ?? 0;
                  int sum7 = data['7']['mins'] ?? 0;

                  return WorkoutChartWidget(
                    weeklyAverage:
                        (sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7) / 7,
                    dailyWorkoutMinutes: [
                      sum1.toDouble(),
                      sum2.toDouble(),
                      sum3.toDouble(),
                      sum4.toDouble(),
                      sum5.toDouble(),
                      sum6.toDouble(),
                      sum7.toDouble(),
                    ],
                  );
                },
              ),
              SizedBox(height: 20 * autoScale),
            ],
          ),
        ),
      ),
    );
  }
}