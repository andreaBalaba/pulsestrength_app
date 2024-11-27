import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/assessment/controller/assessment_controller.dart';
import 'package:pulsestrength/features/assessment/screen/feel_good_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_button.dart';
import 'package:pulsestrength/utils/reusable_text.dart';


class AnyEventPage extends StatefulWidget {
  const AnyEventPage({super.key});

  @override
  State<AnyEventPage> createState() => _AnyEventPageState();
}

class _AnyEventPageState extends State<AnyEventPage> {
  final AssessmentController controller = Get.put(AssessmentController());

  final List<String> icons = [
    IconAssets.pSportIcon,
    IconAssets.pTravelIcon,
    IconAssets.pCameraIcon,
    IconAssets.pVacationIcon,
    IconAssets.pBigDayIcon,
  ];


  double autoScale = Get.width / 400;

  @override
  void initState() {
    super.initState();
    controller.loadAssessmentData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Get.width;
    final screenHeight = Get.height;
    final List<String> choices = controller.eventChoices;


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
                    text: "Goal",
                    size: 20 * autoScale,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: LinearProgressIndicator(
                      value: 0.25,
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
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: screenWidth * 0.01 ),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28 * autoScale,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                children: const [
                  TextSpan(text: "Any special event ", style: TextStyle(color: AppColors.pBlackColor)),
                  TextSpan(text: "boosting ", style: TextStyle(color: AppColors.pSOrangeColor)),
                  TextSpan(text: "your ", style: TextStyle(color: AppColors.pBlackColor)),
                  TextSpan(text: "goal", style: TextStyle(color: AppColors.pSOrangeColor)),
                  TextSpan(text: "?", style: TextStyle(color: AppColors.pBlackColor)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      controller.setSelectedAnyEventsIndex(index);
                      await controller.saveAssessmentAnswer("any_event", choices[index]);
                    },
                    child: Obx(
                          () => Container(
                        margin: EdgeInsets.symmetric(vertical: 14.0 * autoScale),
                        padding: EdgeInsets.all(10.0 * autoScale),
                        decoration: BoxDecoration(
                          color: controller.selectedAnyEventsIndex.value == index
                              ? AppColors.pGreen38Color
                              : AppColors.pWhiteColor,
                          border: Border.all(
                            color: controller.selectedAnyEventsIndex.value == index
                                ? AppColors.pGreenColor
                                : AppColors.pMGreyColor,
                          ),
                          borderRadius: BorderRadius.circular(12.0 * autoScale),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              icons[index],
                              width: 30 * autoScale,
                              height: 30 * autoScale,
                            ),
                            const SizedBox(width: 15.0),
                            Expanded(
                              child: ReusableText(
                                text: choices[index],
                                size: 16 * autoScale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.pBlackColor,
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20.0 * autoScale, right: 20.0 * autoScale, top: 20.0 * autoScale, bottom: 40.0 * autoScale),
        child: SizedBox(
          height: screenHeight * 0.065,
          width: double.infinity,
          child: Obx(
                () => ReusableButton(
              text: "Next",
              onPressed: controller.selectedAnyEventsIndex.value == -1
                  ? null
                  : () async {
                  await controller.saveAssessmentAnswer(
                  "any_event",
                  controller.eventChoices[controller.selectedAnyEventsIndex.value],
                );
                Get.to(() => const FeelGoodPage(), transition: Transition.noTransition);
              },
              color: controller.selectedAnyEventsIndex.value == -1
                  ? AppColors.pNoColor
                  : AppColors.pGreenColor,
              fontColor: AppColors.pWhiteColor,
              borderRadius: 0,
              size: 18 * autoScale,
              weight: FontWeight.w600,
              removePadding: true,
            ),
          ),
        ),
      ),
    );
  }
}
