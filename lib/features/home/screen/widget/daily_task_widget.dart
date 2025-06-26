import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/home/controller/home_controller.dart';
import 'package:pulsestrength/features/home/controller/warm_up_controller.dart';
import 'package:pulsestrength/features/home/screen/cool_down_list.dart';
import 'package:pulsestrength/features/home/screen/daily_task_page.dart';
import 'package:pulsestrength/features/home/screen/warm_up_list.dart';
import 'package:pulsestrength/model/exercise_model.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyTaskList extends StatefulWidget {
  String id;
  List? workouts;
  DailyTaskList({super.key, required this.id, this.workouts});

  @override
  State<DailyTaskList> createState() => _DailyTaskListState();
}

class _DailyTaskListState extends State<DailyTaskList> {
  List<String> completedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedTasks();
  }

  Future<void> _loadCompletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    setState(() {
      completedTasks = prefs.getStringList('completed_tasks_$today') ?? [];
    });
  }

  final WarmUpController warmUpController = Get.put(WarmUpController());

  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 360;
    final HomeController controller = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Daily Task" Header
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ReusableText(
            text: "Daily task",
            size: 24 * autoScale,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Daily Task List
        widget.workouts!.isNotEmpty
            ? ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.workouts!.length,
                itemBuilder: (context, index) {
                  // Sort workouts to put completed tasks at the end
                  final sortedWorkouts = List.from(widget.workouts!)
                    ..sort((a, b) {
                      bool aCompleted = completedTasks.contains(a['exercise']);
                      bool bCompleted = completedTasks.contains(b['exercise']);
                      return aCompleted ? 1 : bCompleted ? -1 : 0;
                    });
                  
                  final task = sortedWorkouts[index];
                  final isCompleted = completedTasks.contains(task['exercise']);

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4 * autoScale),
                    child: GestureDetector(
                      onTap: isCompleted ? null : () => _handleTaskClick(task),
                      child: Container(
                        padding: EdgeInsets.all(10 * autoScale),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.pGreen38Color
                              : AppColors.pNoColor,
                          borderRadius: BorderRadius.circular(12 * autoScale),
                        ),
                        child: Row(
                          children: [
                            // Task Image
                            Container(
                              width: 60.0 * autoScale,
                              height: 60.0 * autoScale,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(8 * autoScale),
                                image: DecorationImage(
                                  image: NetworkImage(task['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 12 * autoScale),
                            // Task Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Task Title
                                  ReusableText(
                                    text: task['exercise'],
                                    fontWeight: FontWeight.w600,
                                    size: 18 * autoScale,
                                    color: AppColors.pBlack87Color,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  // Task Info Chips
                                  Row(
                                    children: [
                                      _buildInfoChip(
                                        iconPath: IconAssets.pClockIcon,
                                        label: "${task['minutes'].toString()} mins",
                                        color: AppColors.pDarkGreenColor,
                                        backgroundColor: AppColors.pNoColor,
                                      ),
                                      SizedBox(width: 8 * autoScale),
                                      _buildInfoChip(
                                        iconPath: IconAssets.pFireIcon,
                                        label:
                                            "${task['calories_burned'].toString()} kcal",
                                        color: AppColors.pDarkOrangeColor,
                                        backgroundColor: AppColors.pNoColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Completion Status Image Icon
                            isCompleted
                                ? Icon(Icons.check_circle, 
                                    color: Colors.green, 
                                    size: 35 * autoScale)
                                : Image.asset(
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
                      Icon(Icons.task_alt, color: Colors.grey, size: 50.0),
                      SizedBox(height: 10.0),
                      ReusableText(
                        text: "No tasks for today!",
                        color: AppColors.pGreyColor,
                        size: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String iconPath,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    double autoScale = Get.width / 360;

    return Container(
      padding: EdgeInsets.all(3.0 * autoScale),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16 * autoScale),
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

  Future<void> _handleTaskClick(Map task) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final completedTasks = prefs.getStringList('completed_tasks_$today') ?? [];
    
    // Check if this is the first task (count is 0) and warm-up is needed
    if (completedTasks.isEmpty) {
      final warmupStatus = prefs.getString('warmup_status_$today');
      if (warmupStatus == null) {
        // Show warm-up first
        final warmupResult = await Get.to(() => const WarmUpP());
        if (warmupResult == 'completed' || warmupResult == 'skipped') {
          await prefs.setString('warmup_status_$today', warmupResult);
        } else {
          return; // Don't proceed if warm-up wasn't completed/skipped
        }
      }
    }

    // Show the task
    final result = await Get.to(() => DailyTaskPage(data: task));
    
    // If task completed and it was the last task, show cool-down
    if (result == 'completed') {
      final updatedCompletedTasks = prefs.getStringList('completed_tasks_$today') ?? [];
      if (updatedCompletedTasks.length == widget.workouts!.length) {
        final cooldownStatus = prefs.getString('cooldown_status_$today');
        if (cooldownStatus == null) {
          final cooldownResult = await Get.to(() => const CoolDownP());
          if (cooldownResult == 'completed' || cooldownResult == 'skipped') {
            await prefs.setString('cooldown_status_$today', cooldownResult);
          }
        }
      }
    }
  }
}

class _DailyTaskCard extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onTap;
  final List? newWorkouts;
  const _DailyTaskCard({
    required this.task,
    required this.onTap,
    required this.newWorkouts,
  });

  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10 * autoScale),
        decoration: BoxDecoration(
          color: newWorkouts!.contains(task.title)
              ? AppColors.pGreen38Color
              : AppColors.pNoColor,
          borderRadius: BorderRadius.circular(12 * autoScale),
        ),
        child: Row(
          children: [
            // Task Image
            Container(
              width: 60.0 * autoScale,
              height: 60.0 * autoScale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8 * autoScale),
                image: DecorationImage(
                  image: AssetImage(task.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12 * autoScale),
            // Task Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  ReusableText(
                    text: task.title,
                    fontWeight: FontWeight.w600,
                    size: 18 * autoScale,
                    color: AppColors.pBlack87Color,
                    decoration: newWorkouts!.contains(task.title)
                        ? TextDecoration.lineThrough
                        : null,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  // Task Info Chips
                  Row(
                    children: [
                      _buildInfoChip(
                        iconPath: IconAssets.pClockIcon,
                        label: task.duration,
                        color: AppColors.pDarkGreenColor,
                        backgroundColor: AppColors.pNoColor,
                      ),
                      SizedBox(width: 8 * autoScale),
                      _buildInfoChip(
                        iconPath: IconAssets.pFireIcon,
                        label: task.calories,
                        color: AppColors.pDarkOrangeColor,
                        backgroundColor: AppColors.pNoColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Completion Status Image Icon
            Image.asset(
              task.isCompleted ? IconAssets.pPlayIcon : IconAssets.pPlayIcon,
              width: 35 * autoScale,
              height: 35 * autoScale,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Method for Info Chips
  Widget _buildInfoChip({
    required String iconPath,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    double autoScale = Get.width / 360;

    return Container(
      padding: EdgeInsets.all(3.0 * autoScale),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16 * autoScale),
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