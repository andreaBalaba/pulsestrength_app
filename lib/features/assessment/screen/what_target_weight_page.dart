import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/assessment/controller/assessment_controller.dart';
import 'package:pulsestrength/features/assessment/screen/we_make_it_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_button.dart';
import 'package:pulsestrength/utils/reusable_text.dart';


class TargetWeightPage extends StatefulWidget {
  const TargetWeightPage({super.key});

  @override
  State<TargetWeightPage> createState() => _TargetWeightPageState();
}

class _TargetWeightPageState extends State<TargetWeightPage> {
  final AssessmentController controller = Get.put(AssessmentController());
  late PageController _pageController;
  bool isPageControllerInitialized = false;
  final double autoScale = Get.width / 400;
  final int minWeight = 30;

  Future<void> _initializePageController() async {
    await controller.loadAssessmentData();  // Load data
    int initialWeight = controller.targetWeight.value;
    _pageController = PageController(
      viewportFraction: 0.25,
      initialPage: initialWeight - minWeight,
    );

    controller.calculateWeightChangeFeedback();

    _pageController.addListener(() {
      int middleIndex = _pageController.page!.round();
      setState(() {
        controller.targetWeight.value = middleIndex + minWeight;
      });
      controller.calculateWeightChangeFeedback();
    });

    setState(() {
      isPageControllerInitialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializePageController();
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = Get.width;
    final screenHeight = Get.height;

    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.pBGWhiteColor,
        surfaceTintColor: AppColors.pNoColor,
        toolbarHeight: 60,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, size: 28 * autoScale, color: AppColors.pBlackColor),
                  padding: const EdgeInsets.all(8.0),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ReusableText(
                    text: "Body data",
                    size: 20 * autoScale,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: LinearProgressIndicator(
                      value: 0.5,
                      minHeight: 9.0 * autoScale,
                      color: AppColors.pGreenColor,
                      backgroundColor: AppColors.pMGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(height: 20.0),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isPageControllerInitialized
          ? Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: screenWidth * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28 * autoScale,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                children: const [
                  TextSpan(text: "What is your ", style: TextStyle(color: AppColors.pBlackColor)),
                  TextSpan(text: "target ", style: TextStyle(color: AppColors.pSOrangeColor)),
                  TextSpan(text: "weight?", style: TextStyle(color: AppColors.pBlackColor)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20 * autoScale),
                child: Center(
                  child: ListView(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.5,
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.asset(
                            ImageAssets.pTargetWeightPic,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 80,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: 151,
                              itemBuilder: (context, index) {
                                final weight = index + minWeight;
                                return Center(
                                  child: ReusableText(
                                    text: "$weight",
                                    size: weight == controller.targetWeight.value
                                        ? 30 * autoScale
                                        : 20 * autoScale,
                                    color: weight == controller.targetWeight.value
                                        ? AppColors.pBlackColor
                                        : AppColors.pGreyColor,
                                    fontWeight: weight == controller.targetWeight.value
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.pSOrangeColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(width: 60),
                                  Container(
                                    height: 60,
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.pSOrangeColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: ReusableText(
                          text: "Kg",
                          size: 16 * autoScale,
                          color: AppColors.pBlackColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Obx(() => Container(
                        width: screenWidth * 0.75,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReusableText(
                              text: controller.weightChangeHeader.value,
                              size: 18 * autoScale,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 5),
                            ReusableText(
                              text: controller.weightChangeSemiHeader.value,
                              size: 14 * autoScale,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 5),
                            ReusableText(
                              text: controller.weightChangeMessage.value,
                              size: 14 * autoScale,
                              color: AppColors.pDarkGreyColor,
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator(color: AppColors.pGreenColor,)),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20.0 * autoScale, right: 20.0 * autoScale, top: 10.0 * autoScale, bottom: 40.0 * autoScale),
        child: SizedBox(
          height: screenHeight * 0.065,
          child: ReusableButton(
            text: "Next",
            onPressed: () {
              controller.saveAssessmentDataToDatabase();
              Get.to(() => const WeMakeItPage(), transition: Transition.noTransition);
            },
            color: AppColors.pGreenColor,
            fontColor: AppColors.pWhiteColor,
            borderRadius: 0,
            size: 18 * autoScale,
            weight: FontWeight.w600,
            removePadding: true,
          ),
        ),
      ),
    );
  }
}