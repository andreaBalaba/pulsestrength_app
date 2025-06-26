import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/home/screen/cool_down_detail_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_button.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class CoolDownP extends StatefulWidget {
  const CoolDownP({super.key});

  @override
  State<CoolDownP> createState() => _CoolDownPState();
}

class _CoolDownPState extends State<CoolDownP> {
  Map<String, String> cooldownStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadCooldownStatuses();
  }

  Future<void> _loadCooldownStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().weekday.toString();
    final statuses = prefs.getStringList('cooldown_statuses_$today') ?? [];
    
    setState(() {
      cooldownStatuses = Map.fromEntries(
        statuses.map((status) {
          final parts = status.split(':');
          return MapEntry(parts[0], parts[1]);
        }),
      );
    });
  }

  Future<void> _updateCooldownStatus(String cooldownId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().weekday.toString();
    
    setState(() {
      cooldownStatuses[cooldownId] = status;
    });

    final statusList = cooldownStatuses.entries
        .map((e) => '${e.key}:${e.value}')
        .toList();
    await prefs.setStringList('cooldown_statuses_$today', statusList);
  }

  @override
  Widget build(BuildContext context) {
    print('CoolDownP: Building page');
    double autoScale = Get.width / 360;
    double screenHeight = Get.height;

    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.pBGWhiteColor,
        surfaceTintColor: AppColors.pNoColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const ReusableText(
          text: 'Cool Down',
          fontWeight: FontWeight.bold,
          size: 20,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: 'skipped');
            },
            child: const ReusableText(text: 'Skip'),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref('users/${FirebaseAuth.instance.currentUser!.uid}')
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          try {
            dynamic data = snapshot.data!.snapshot.value;
            List cooldowns = data['workouts']['weekly_schedule']
                [DateTime.now().weekday - 1]['cool_down'] ?? [];

            return Scaffold(
              backgroundColor: AppColors.pBGWhiteColor,
              body: cooldowns.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.all(16 * autoScale),
                      itemCount: cooldowns.length,
                      itemBuilder: (context, index) {
                        final cooldown = cooldowns[index];
                        final cooldownId = '${cooldown['activity']}_$index';
                        final status = cooldownStatuses[cooldownId] ?? 'notStarted';
                        final isCompleted = status == 'completed';
                        final isSkipped = status == 'skipped';
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4 * autoScale),
                          child: GestureDetector(
                            onTap: isCompleted || isSkipped ? null : () async {
                              final result = await Get.to(
                                () => CoolDownDetailPage(
                                  data: cooldown,
                                  cooldowns: cooldowns,
                                  currentIndex: index,
                                ),
                                transition: Transition.rightToLeft,
                              );
                              
                              if (result == 'completed' || result == 'skipped') {
                                await _updateCooldownStatus(cooldownId, result);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(10 * autoScale),
                              decoration: BoxDecoration(
                                color: isCompleted 
                                  ? AppColors.pGreen38Color
                                  : isSkipped 
                                    ? Colors.grey[200]
                                    : AppColors.pNoColor,
                                borderRadius: BorderRadius.circular(12 * autoScale),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60.0 * autoScale,
                                    height: 60.0 * autoScale,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8 * autoScale),
                                      image: DecorationImage(
                                        image: NetworkImage(cooldown['image']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12 * autoScale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ReusableText(
                                          text: cooldown['activity'],
                                          fontWeight: FontWeight.w600,
                                          size: 18 * autoScale,
                                          color: isSkipped ? Colors.grey : AppColors.pBlack87Color,
                                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        if (isCompleted || isSkipped)
                                          ReusableText(
                                            text: isCompleted ? "Completed" : "Skipped",
                                            size: 14 * autoScale,
                                            color: isCompleted ? Colors.green : Colors.grey,
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isCompleted)
                                    Icon(Icons.check_circle, color: Colors.green, size: 35 * autoScale)
                                  else if (isSkipped)
                                    Icon(Icons.skip_next, color: Colors.grey, size: 35 * autoScale)
                                  else
                                    Image.asset(
                                      IconAssets.pPlayIcon,
                                      width: 35 * autoScale,
                                      height: 35 * autoScale,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center, color: Colors.grey, size: 50.0),
                            SizedBox(height: 10.0),
                            ReusableText(
                              text: "No cool-downs available!",
                              color: AppColors.pGreyColor,
                              size: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
              bottomNavigationBar: cooldowns.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: 20.0 * autoScale,
                        right: 20.0 * autoScale,
                        top: 20.0 * autoScale,
                        bottom: 40.0 * autoScale,
                      ),
                      child: SizedBox(
                        height: screenHeight * 0.065,
                        width: double.infinity,
                        child: ReusableButton(
                          text: cooldownStatuses.length == cooldowns.length ? "Finish" : "Start",
                          onPressed: () {
                            if (cooldownStatuses.length == cooldowns.length) {
                              Get.back(result: 'completed');
                            } else {
                              Get.to(
                                () => CoolDownDetailPage(
                                  data: cooldowns[0],
                                  cooldowns: cooldowns,
                                  currentIndex: 0,
                                ),
                                transition: Transition.rightToLeft,
                              );
                            }
                          },
                          color: AppColors.pGreenColor,
                          fontColor: AppColors.pWhiteColor,
                          borderRadius: 30.0 * autoScale,
                          size: 18 * autoScale,
                          weight: FontWeight.w600,
                          removePadding: true,
                        ),
                      ),
                    )
                  : null,
            );
          } catch (e) {
            print('CoolDownP: Error processing data: $e');
            return Center(child: Text('Error processing data: $e'));
          }
        },
      ),
    );
  }
}