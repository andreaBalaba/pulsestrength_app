import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/assessment/controller/assessment_controller.dart';
import 'package:pulsestrength/features/assessment/screen/any_special_event_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_button.dart';
import 'package:pulsestrength/utils/reusable_text.dart';


class FocusAreaPage extends StatefulWidget {
  const FocusAreaPage({super.key});

  @override
  State<FocusAreaPage> createState() => _FocusAreaPageState();
}

class _FocusAreaPageState extends State<FocusAreaPage> {
  final AssessmentController controller = Get.put(AssessmentController());

  final List<String> images = [
    ImageAssets.pArmPic,
    ImageAssets.pChestPic,
    ImageAssets.pBellyPic,
    ImageAssets.pGlutesPic,
    ImageAssets.pThighPic,
    ImageAssets.pFullBodyPic,
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
    final List<String> choices = controller.focusAreaChoices;



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
                      value: 0.2,
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
                  TextSpan(text: "What's your ", style: TextStyle(color: AppColors.pBlackColor)),
                  TextSpan(text: "focus ", style: TextStyle(color: AppColors.pSOrangeColor)),
                  TextSpan(text: "area?", style: TextStyle(color: AppColors.pBlackColor)),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15.0),
            Expanded(
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.14,
                  crossAxisSpacing: 12 * autoScale,
                  mainAxisSpacing: 12 * autoScale,
                ),
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      controller.setSelectedFocusAreaIndex(index);
                      await controller.saveAssessmentAnswer("focus_area", choices[index]);
                    },
                    child: Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: controller.selectedFocusAreaIndex.value == index
                              ? AppColors.pGreenColor
                              : AppColors.pMGreyColor,
                        ),
                        borderRadius: BorderRadius.circular(12.0 * autoScale),
                        color: controller.selectedFocusAreaIndex.value == index
                            ? AppColors.pGreen38Color
                            : AppColors.pWhiteColor,
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReusableText(
                                  text: choices[index],
                                  size: 18 * autoScale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -1,
                            left: -1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0 * autoScale),
                              child: Image.asset(
                                images[index],
                                width: 100.0 * autoScale,
                                height: 100.0 * autoScale,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Obx(
                                  () => Radio<int>(
                                value: index,
                                groupValue: controller.selectedFocusAreaIndex.value,
                                onChanged: (int? value) {
                                  controller.selectedFocusAreaIndex.value = value ?? -1;
                                },
                                activeColor: AppColors.pGreenColor,
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20.0 * autoScale, right: 20.0 * autoScale, top: 20.0 * autoScale, bottom: 40.0 * autoScale),
        child: SizedBox(
          height: screenHeight * 0.065,
          width: double.infinity,
          child: Obx(
                () => ReusableButton(
              text: "Next",
              onPressed: controller.selectedFocusAreaIndex.value == -1
                  ? null
                  : () async {
                await controller.saveAssessmentAnswer(
                  "focus_area",
                  controller.focusAreaChoices[controller.selectedFocusAreaIndex.value],
                );

                Get.to(() => const AnyEventPage(), transition: Transition.noTransition);
              },
              color: controller.selectedFocusAreaIndex.value == -1
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
