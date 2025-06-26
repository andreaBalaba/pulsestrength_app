
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pulsestrength/features/home/controller/home_controller.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:firebase_database/firebase_database.dart';

class PlanCardWidget extends StatelessWidget {
  int count;

  PlanCardWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    double autoScale = Get.width / 360;

    return StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref('users/${FirebaseAuth.instance.currentUser!.uid}')
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading'));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          dynamic userData = snapshot.data!.snapshot.value;

          List workouts = userData['workouts']['weekly_schedule']
                  [DateTime.now().weekday - 1]['exercises'] ??
              [];

          return Container(
            child: StreamBuilder<DatabaseEvent>(
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
                  return Obx(() => Card(
                        color: AppColors.pOrangeColor,
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12.0 * autoScale)),
                        child: Padding(
                          padding: EdgeInsets.all(16.0 * autoScale),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ReusableText(
                                    text: "My plan\nfor Today",
                                    size: 28.0 * autoScale,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.pWhiteColor,
                                  ),
                                  SizedBox(height: 8.0 * autoScale),
                                  ReusableText(
                                    text:
                                        "${data[DateTime.now().weekday.toString()]['workouts']}/${workouts.length} Complete",
                                    size: 16.0 * autoScale,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.pWhite70Color,
                                  ),
                                ],
                              ),
                              CircularPercentIndicator(
                                radius: 60.0 * autoScale,
                                lineWidth: 8.0 * autoScale,
                                percent:
                                    ((data[DateTime.now().weekday.toString()]
                                                        ['workouts'] /
                                                    workouts.length *
                                                    100)
                                                .round() *
                                            0.01)
                                        .toDouble(),
                                center: ReusableText(
                                  text: controller.totalTasksCount > 0
                                      ? "${(data[DateTime.now().weekday.toString()]['workouts'] / workouts.length * 100).round()}%"
                                      : "0%",
                                  size: 32 * autoScale,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pWhiteColor,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Colors.black26,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                                progressColor: AppColors.pGreenColor,
                                backgroundColor: AppColors.pMGreyColor,
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                            ],
                          ),
                        ),
                      ));
                }),
          );
        });
  }
}