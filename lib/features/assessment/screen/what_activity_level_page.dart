import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/assessment/controller/assessment_controller.dart';
import 'package:pulsestrength/features/assessment/screen/flexibility_level_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:pulsestrength/utils/reusable_button.dart';


class ActivityLevelPage extends StatefulWidget {
  const ActivityLevelPage({super.key});

  @override
  State<ActivityLevelPage> createState() => _ActivityLevelPageState();
}

class _ActivityLevelPageState extends State<ActivityLevelPage> {
  final AssessmentController controller = Get.put(AssessmentController());
  final double autoScale = Get.width / 400;
  double sliderValue = 0.0;
  String selectedLabel = "Sedentary";
  String description = "I seldom exercise and spend most of my time sitting.";
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    controller.loadAssessmentData().then((_) {
      setState(() {
        if (controller.selectedActivityLevel.value.isNotEmpty) {
          selectedLabel = controller.selectedActivityLevel.value;
          sliderValue = _getSliderValueForLabel(selectedLabel);
        }
        isDataLoaded = true;
      });
    });
  }

  double _getSliderValueForLabel(String label) {
    switch (label) {
      case "Sedentary":
        return 0.0;
      case "Lightly Active":
        return 0.33;
      case "Moderately Active":
        return 0.66;
      case "Very Active":
        return 1.0;
      default:
        return 0.0;
    }
  }


  String _getCustomLabelForSlider(double value) {
    if (value <= 0.25) return "Sedentary";
    if (value <= 0.5) return "Lightly Active";
    if (value <= 0.75) return "Moderately Active";
    return "Very Active";
  }

  String _getDescriptionForLabel(String label) {
    switch (label) {
      case "Sedentary":
        return "I seldom exercise and spend most of my time sitting.";
      case "Lightly Active":
        return "I engage in occasional walks or light exercise to stay active.";
      case "Moderately Active":
        return "I do  moderate exercises several times a week for overall health.";
      case "Very Active":
        return "I’m involved in physical activity for several hours every day.";
      default:
        return "";
    }
  }

  String getImageForSliderValue(double value) {
    if (value <= 0.25) return ImageAssets.pSedentary;
    if (value <= 0.5) return ImageAssets.pLightlyActive;
    if (value <= 0.75) return ImageAssets.pModerately;
    return ImageAssets.pVeryActive;
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
                    text: "Fitness analysis",
                    size: 20 * autoScale,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: LinearProgressIndicator(
                      value: 0.7,
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
      body: isDataLoaded  // Show content only when data is loaded
          ? Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * autoScale, vertical: 20 * autoScale),
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
                      TextSpan(text: "activity ", style: TextStyle(color: AppColors.pSOrangeColor)),
                      TextSpan(text: "level ?", style: TextStyle(color: AppColors.pBlackColor)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * autoScale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 5,
                      child: SizedBox(
                        width: screenWidth * 0.9,
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.asset(
                            getImageForSliderValue(sliderValue),
                            fit: BoxFit.contain,
                            color: AppColors.pSOrangeColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * autoScale),
                    ReusableText(
                      text: selectedLabel,
                      size: 24 * autoScale,
                      fontWeight: FontWeight.bold,
                      align: TextAlign.center,
                    ),
                    SizedBox(height: 10 * autoScale),
                    ReusableText(
                      text: description,
                      align: TextAlign.center,
                      size: 18 * autoScale,
                      fontWeight: FontWeight.w300,
                    ),
                    SizedBox(height: 20 * autoScale),
                  ],
                ),
              ),
            ),
          ),
          _buildSlider(),
          SizedBox(height: 10 * autoScale),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ReusableText(text: "Sedentary", size: 14 * autoScale, fontWeight: FontWeight.w500),
                ReusableText(text: "Very Active", size: 14 * autoScale, fontWeight: FontWeight.w500),
              ],
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator(color: AppColors.pGreenColor,)),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20.0 * autoScale, right: 20.0 * autoScale, top: 20.0 * autoScale, bottom: 40.0 * autoScale),
        child: SizedBox(
          height: screenHeight * 0.065,
          width: double.infinity,
          child: ReusableButton(
            text: "Next",
            onPressed: () {

              controller.selectedActivityLevel.value = selectedLabel;
              controller.saveAssessmentAnswer("activity_level", selectedLabel);
              Get.to(() => const FlexibilityLevelPage(), transition: Transition.noTransition);

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

  Widget _buildSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 20,
        thumbShape: CustomSliderThumb(),
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: Colors.transparent,
        inactiveTrackColor: AppColors.pMGreyColor,
        trackShape: GradientTrackShape(trackPadding: 16.0),
      ),
      child: Slider(
        value: sliderValue,
        min: 0.0,
        max: 1.0,
        divisions: 3,
        onChanged: (value) {
          setState(() {
            sliderValue = value;
            selectedLabel = _getCustomLabelForSlider(value);
            description = _getDescriptionForLabel(selectedLabel);
            controller.selectedActivityLevel.value = selectedLabel;
          });
        },
      ),
    );
  }
}

// Custom slider thumb shape
class CustomSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final double borderWidth;

  CustomSliderThumb({this.thumbRadius = 12.0, this.borderWidth = 2.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(thumbRadius);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final thumbPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = AppColors.pSOrangeColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    context.canvas.drawCircle(center, thumbRadius, thumbPaint);
    context.canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}

// Custom track shape for slider gradient
class GradientTrackShape extends SliderTrackShape {
  final double trackPadding;

  GradientTrackShape({this.trackPadding = 20.0});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2.0;
    final trackLeft = offset.dx + trackPadding;
    final trackWidth = parentBox.size.width - 2 * trackPadding;
    return Rect.fromLTWH(trackLeft, offset.dy + (parentBox.size.height - trackHeight) / 2, trackWidth, trackHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        Offset? secondaryOffset, // Include secondaryOffset to match the method signature
        bool isEnabled = false,
        bool isDiscrete = false,
      }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );

    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.pSOrangeColor, Colors.white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx + 10, trackRect.bottom));

    final inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor ?? AppColors.pGreyColor;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom), const Radius.circular(10)),
      activePaint,
    );

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom), const Radius.circular(10)),
      inactivePaint,
    );
  }
}
