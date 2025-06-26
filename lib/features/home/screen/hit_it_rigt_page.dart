import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/home/screen/daily_task_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class HitItRigtPage extends StatefulWidget {
  dynamic data;

  HitItRigtPage({super.key, required this.data});

  @override
  State<HitItRigtPage> createState() => _HitItRigtPageState();
}

class _HitItRigtPageState extends State<HitItRigtPage> {
  int totalItems = 0;
  List<bool> isChecked = [];
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    totalItems = widget.data['plan_info'].first['plan_workouts'].length;
    isChecked = List.generate(totalItems, (index) => false);
    _loadCheckboxState();
  }

  Future<void> _loadCheckboxState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final planId = widget.data['name'];
    final lastDate = prefs.getString('hit_it_right_last_date_$planId');
    final hasUpdatedFirestore = prefs.getBool('hit_it_right_firebase_updated_${planId}_$today') ?? false;
    
    // Reset checkboxes if it's a new day
    if (lastDate != today) {
      setState(() {
        isChecked = List.generate(totalItems, (index) => false);
      });
      await prefs.setString('hit_it_right_last_date_$planId', today);
      await prefs.setStringList('hit_it_right_checked_${planId}_$today', []);
      await prefs.setBool('hit_it_right_firebase_updated_${planId}_$today', false);
    } else {
      final savedChecked = prefs.getStringList('hit_it_right_checked_${planId}_$today') ?? [];
      setState(() {
        isChecked = List.generate(totalItems, (index) => savedChecked.contains(index.toString()));
        completedCount = savedChecked.length;
      });
    }
  }

  void toggleCheckbox(int index, bool? value) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final planId = widget.data['name'];
    final hasUpdatedFirestore = prefs.getBool('hit_it_right_firebase_updated_${planId}_$today') ?? false;
    
    setState(() {
      isChecked[index] = value ?? false;
      completedCount = isChecked.where((checked) => checked).length;
    });

    // Save checked state for this specific plan
    List<String> checkedIndices = [];
    for (int i = 0; i < isChecked.length; i++) {
      if (isChecked[i]) checkedIndices.add(i.toString());
    }
    await prefs.setStringList('hit_it_right_checked_${planId}_$today', checkedIndices);

    // If all tasks in this plan are completed and haven't updated Firestore today
    if (completedCount == totalItems && !hasUpdatedFirestore) {
      int totalMinutes = widget.data['plan_info'].first['plan_workouts']
          .fold(0, (sum, workout) => sum + workout['minutes']);

      final databaseRef = FirebaseDatabase.instance.ref();
      final weeklyRef = databaseRef.child('users/${FirebaseAuth.instance.currentUser!.uid}/Weekly');
      final weekdayRef = weeklyRef.child(DateTime.now().weekday.toString());

      await weekdayRef.update({
        'calories': ServerValue.increment(widget.data['plan_calories_burned']),
        'mins': ServerValue.increment(totalMinutes),
      });

      // Mark this specific plan as updated for today
      await prefs.setBool('hit_it_right_firebase_updated_${planId}_$today', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.pBGWhiteColor,
        surfaceTintColor: AppColors.pNoColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  ReusableText(
                    text: widget.data['name'],
                    fontWeight: FontWeight.bold,
                    size: 28,
                    color: AppColors.pBlackColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 10),
                  _buildInfoChip(
                    context,
                    iconPath: IconAssets.pFireIcon,
                    label: "${widget.data['plan_calories_burned']} kcal",
                    color: AppColors.pDarkOrangeColor,
                    backgroundColor: AppColors.pLightOrangeColor,
                    borderColor: AppColors.pDarkOrangeColor,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ReusableText(
                text: widget.data['plan_info'].first['plan_overview'].join('\n\n'),
                fontWeight: FontWeight.normal,
                size: 12,
                color: AppColors.pDarkGreyColor,
                overflow: TextOverflow.ellipsis,
                align: TextAlign.justify,
                maxLines: 6,
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              const ReusableText(
                text: 'Exercise',
                fontWeight: FontWeight.bold,
                size: 24,
                color: AppColors.pBlackColor,
                overflow: TextOverflow.ellipsis,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  '$completedCount/$totalItems Complete',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.data['plan_info'].first['plan_workouts'].length,
                  itemBuilder: (context, index) {
                    final workout = widget.data['plan_info'].first['plan_workouts'][index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: isChecked[index] ? null : () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DailyTaskPage(
                                    calories: widget.data['plan_calories_burned'],
                                    data: workout,
                                  )));
                        },
                        child: Container(
                          width: double.infinity,
                          height: 75,
                          decoration: BoxDecoration(
                            color: isChecked[index]
                                ? AppColors.pGreen38Color
                                : AppColors.pGrey400Color,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                checkColor: Colors.black,
                                activeColor: Colors.white,
                                hoverColor: Colors.white,
                                value: isChecked[index],
                                onChanged: (value) => toggleCheckbox(index, value),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  image: DecorationImage(
                                    image: NetworkImage(workout['image']),
                                    fit: BoxFit.cover
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workout['exercise'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Set ${workout['sets']} ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 13,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          const Text(
                                            ' - ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          Text(
                                            '${workout['reps']} Reps',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 25),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String iconPath,
    required String label,
    required Color color,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    double autoScale = Get.width / 360;

    return Container(
      padding: EdgeInsets.all(3.0 * autoScale),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0 * autoScale),
        border: Border.all(color: borderColor, width: 1.0 * autoScale),
      ),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            height: 12.0 * autoScale,
            width: 12.0 * autoScale,
            color: color,
          ),
          SizedBox(width: 4.0 * autoScale),
          ReusableText(
            text: label,
            size: 11.0 * autoScale,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ],
      ),
    );
  }
}
