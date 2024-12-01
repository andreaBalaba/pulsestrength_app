import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/home/controller/home_controller.dart';
import 'package:pulsestrength/model/exercise_model.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class DailyTaskList extends StatelessWidget {
  const DailyTaskList({super.key});

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
        Obx(() {
          return controller.dailyTasks.isNotEmpty
              ? ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.dailyTasks.length,
            itemBuilder: (context, index) {
              final task = controller.dailyTasks[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4 * autoScale),
                child: _DailyTaskCard(
                  task: task,
                  onTap: () {
                    task.isCompleted = !task.isCompleted;
                    controller.dailyTasks.refresh();
                  },
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
          );
        }),
      ],
    );
  }
}

class _DailyTaskCard extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onTap;

  const _DailyTaskCard({
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10 * autoScale),
        decoration: BoxDecoration(
          color: task.isCompleted ? AppColors.pGreen38Color : AppColors.pNoColor,
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
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
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