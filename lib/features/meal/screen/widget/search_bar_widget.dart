import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/meal/controller/meal_controller.dart';
import 'package:pulsestrength/utils/global_variables.dart';

class SearchBarWidget extends StatelessWidget implements PreferredSizeWidget {
  SearchBarWidget({super.key});

  final MealController controller = Get.put(MealController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 360;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0 * autoScale),
      decoration: BoxDecoration(
        color: AppColors.pLightGreyColor,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.pGreyColor),
          const SizedBox(width: 5),
          Expanded(
            child: TextField(
              controller: textController,
              onChanged: controller.updateSearchQuery,
              cursorColor: AppColors.pBlackColor,
              decoration: const InputDecoration(
                hintText: 'Search food',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black54, fontFamily: 'Poppins'),
              ),
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
            onTap: () {
              controller.clearSearch();
              textController.clear(); // Clears the TextField content
            },
            child: const Icon(Icons.close, color: AppColors.pGreyColor),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0); // Height for AppBar
}
