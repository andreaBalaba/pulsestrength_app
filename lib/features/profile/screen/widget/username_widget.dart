import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/home/controller/home_controller.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class UserHeader extends StatelessWidget {

  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());
    final autoScale = Get.width / 400;

    return Column(
      children: [
        Center(
          child: CircleAvatar(
            backgroundImage: const AssetImage(IconAssets.pUserIcon),
            radius: 50 * autoScale,
          ),
        ),
        SizedBox(height: 16 * autoScale),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 40 * autoScale),
              Flexible(
                child: Obx(() {
                  final username = homeController.username.value;
                  if (username == null) {
                    return ReusableText(
                      text: "Loading...",
                      size: 24 * autoScale,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return ReusableText(
                    text: username,
                    size: 24 * autoScale,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 20 * autoScale,
                  color: AppColors.pGreyColor,
                ),
                onPressed: () {
                  // Implement edit functionality here
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}