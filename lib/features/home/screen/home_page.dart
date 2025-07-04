import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/api/services/add_daily_plan.dart';
import 'package:pulsestrength/api/services/add_weekly.dart';
import 'package:pulsestrength/features/chatbot/controller/chatbot_controller.dart';
import 'package:pulsestrength/features/chatbot/new_chatbot_page.dart';
import 'package:pulsestrength/features/home/controller/home_controller.dart';
import 'package:pulsestrength/features/home/screen/widget/daily_task_widget.dart';
import 'package:pulsestrength/features/home/screen/widget/today_plan_card_widget.dart';
import 'package:pulsestrength/features/home/screen/widget/workout_plan_widget.dart';
import 'package:pulsestrength/features/library/screen/library_page.dart';
import 'package:pulsestrength/features/meal/screen/meal_page.dart';
import 'package:pulsestrength/features/profile/screen/profile_page.dart';
import 'package:pulsestrength/features/progress/screen/progress_page.dart';
import 'package:pulsestrength/features/settings/screen/setting_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController homeController = Get.put(HomeController());
  final ChatBotController botController = Get.put(ChatBotController());

  int _currentIndex = 0;
  bool _isButtonDragged = false;
  bool _showShadow = false;
  double _buttonVerticalPosition = 0;
  double autoScale = Get.width / 400;

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final GlobalKey _dailyTaskKey = GlobalKey();

   @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    getWeeklyData();
    getDailyData();
  }

  bool hasLoaded = false;
  dynamic dailyData;
  getDailyData() {
    FirebaseDatabase.instance
        .ref('users/${FirebaseAuth.instance.currentUser!.uid}/Daily Plan')
        .orderByChild('date')
        .equalTo('${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}')
        .once()
        .then((snapshot) {
      if (snapshot.snapshot.value != null) {
        setState(() {
          dailyData = snapshot.snapshot.value;
          hasLoaded = true;
        });
      } else {
        final json = addDailyPlan();
        setState(() {
          dailyData = json;
          dailyData['workouts'] = [];
          hasLoaded = true;
        });
      }
    });
  }

  getWeeklyData() {
    FirebaseDatabase.instance
        .ref('users/${FirebaseAuth.instance.currentUser!.uid}/Weekly')
        .once()
        .then((snapshot) {
      if (snapshot.snapshot.value != null) {
        if (DateTime.now().weekday == 1) {
          Map<String, dynamic>? weeklyData = snapshot.snapshot.value as Map<String, dynamic>?;
          if (weeklyData?['year'] != DateTime.now().year.toString() &&
              weeklyData?['month'] != DateTime.now().month.toString() &&
              weeklyData?['day'] != DateTime.now().day.toString()) {
            addWeekly();
          }
        }
      } else {
        addWeekly();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_currentIndex == 0) { // Only listen for shadow changes in Home
      if (_scrollController.position.pixels > 0 && !_showShadow) {
        setState(() {
          _showShadow = true;
        });
      } else if (_scrollController.position.pixels <= 0 && _showShadow) {
        setState(() {
          _showShadow = false;
        });
      }
    }
  }


  void _scrollToDailyTask() {
    final RenderBox? renderBox = _dailyTaskKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero).dy;
      _scrollController.animateTo(
        _scrollController.offset + position - 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = Get.height;

    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.pBGWhiteColor,
        elevation: _currentIndex == 0 && _showShadow ? 4.0 : 0.0,
        surfaceTintColor: AppColors.pNoColor,
        shadowColor: _showShadow ? Colors.black26 : Colors.transparent,
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
            Get.to(() => const ProfilePage(), transition: Transition.noTransition);
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
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildHomeContent(),
              const LibraryPage(),
              ChatBotScreen(gender: botController.gender.value, age: botController.age.value, height: botController.height.value, weight: botController.weight.value, isDisabled: false),
              StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance
                      .ref('users/${FirebaseAuth.instance.currentUser!.uid}')
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

                    return ProgressPage(
                      data: dailyData ?? {},
                      id: FirebaseAuth.instance.currentUser!.uid,
                      workouts: data['workouts']['weekly_schedule']
                              [DateTime.now().weekday - 1]['exercises'] ??
                          [],
                    );
                  }),
              const MealPage()
            ],
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
                  Get.to(() => ChatBotScreen(gender: botController.gender.value, age: botController.age.value, height: botController.height.value, weight: botController.weight.value, isDisabled: false), preventDuplicates: true);
                } else {
                  setState(() {
                    _currentIndex = index;
                    _pageController.jumpToPage(index);
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

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0 * autoScale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15 * autoScale),
            hasLoaded
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0 * autoScale),
                    child: GestureDetector(
                      onTap: _scrollToDailyTask,
                      child: PlanCardWidget(
                        count: dailyData['workouts'] == null
                            ? 0
                            : dailyData['workouts'].length,
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            SizedBox(height: 20 * autoScale),
            const WorkoutPlanList(),
            SizedBox(height: 15 * autoScale),
            StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref('users/${FirebaseAuth.instance.currentUser!.uid}')
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

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0 * autoScale),
                    child: DailyTaskList(
                      key: _dailyTaskKey,
                      id: FirebaseAuth.instance.currentUser!.uid,
                      workouts: data['workouts']['weekly_schedule']
                              [DateTime.now().weekday - 1]['exercises'] ??
                          [],
                    ),
                  );
                }),
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
