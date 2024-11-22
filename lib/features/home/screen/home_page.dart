import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/chatbot/screen/chatbot_page.dart';
import 'package:pulsestrength/features/home/controller/home_controller.dart';
import 'package:pulsestrength/features/settings/screen/setting_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController homeController = Get.put(HomeController());
  int _currentIndex = 0;
  bool _isButtonDragged = false;
  double _buttonVerticalPosition = 0;


  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 400;
    double screenHeight = Get.height;

    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.pBGWhiteColor,
        elevation: 0,
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
        title: GestureDetector(
          onTap: () {
            // Handle profile icon tap
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: const AssetImage(IconAssets.pUserIcon),
                radius: 18 * autoScale,
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Obx(() {
                  final username = homeController.username.value;
                  if (username == null) {
                    return ReusableText(
                      text: "Loading...",
                      size: 22 * autoScale,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                  return ReusableText(
                    text: username,
                    size: 22 * autoScale,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: ReusableText(
              text: "Content goes here",
              fontWeight: FontWeight.w600,
              size: 20 * autoScale,
              color: AppColors.pBlackColor,
            ),
          ),
          Positioned(
            top: _isButtonDragged ? _buttonVerticalPosition : 0,
            left: 0,
            child: GestureDetector(
              onTap: () {
                homeController.navigateToCalculator();
              },
              child: Image.asset(
                IconAssets.pSideIcon,
                width: 30.0,
                height: 30.0,
                fit: BoxFit.contain,
              ),
              onPanUpdate: (details) {
                setState(() {
                  _isButtonDragged = true;
                  _buttonVerticalPosition =
                      (details.globalPosition.dy - 40).clamp(
                        0,
                        screenHeight - 250,
                      );
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.pBGWhiteColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.pBlack12Color,
              offset: Offset(0, -2),
              blurRadius: 15.0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            BottomNavigationBar(
              backgroundColor: AppColors.pBGWhiteColor,
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 2) {
                  Get.to(() => const ChatBotPage(), preventDuplicates: true);
                } else {
                  setState(() {
                    _currentIndex = index;
                   // _pageController.jumpToPage(index);
                  });
                }
              },
              type: BottomNavigationBarType.fixed,
              items: [
                _buildNavItem(
                  icon: IconAssets.pHomeIcon,
                  selectedIcon: IconAssets.pHomeIconSelected,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                ),
                _buildNavItem(
                  icon: IconAssets.pLibIcon,
                  selectedIcon: IconAssets.pLibIconSelected,
                  label: 'Library',
                  isSelected: _currentIndex == 1,
                ),
                _buildNavItem(
                  icon: IconAssets.pChatBotIcon,
                  selectedIcon: IconAssets.pChatBotIcon,
                  label: 'ChatBot',
                  isSelected: _currentIndex == 2,
                ),
                _buildNavItem(
                  icon: IconAssets.pProgressIcon,
                  selectedIcon: IconAssets.pProgressIconSelected,
                  label: 'Progress',
                  isSelected: _currentIndex == 3,
                ),
                _buildNavItem(
                  icon: IconAssets.pMealIcon,
                  selectedIcon: IconAssets.pMealIconSelected,
                  label: 'Meal',
                  isSelected: _currentIndex == 4,
                ),
              ],
              selectedItemColor: AppColors.pGreenColor,
              unselectedItemColor: AppColors.pBlackColor,
              showUnselectedLabels: true,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12 * autoScale,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12 * autoScale,
              ),
            ),
            Positioned(
              top: -4,
              left: _currentIndex * (Get.width / 5) + (Get.width / 10) - 25,
              child: Image.asset(
                IconAssets.pLine,
                width: 50,
                height: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required String icon,
    required String selectedIcon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        isSelected ? selectedIcon : icon,
        height: 30 * (Get.width / 400),
      ),
      label: label,
    );
  }
}
