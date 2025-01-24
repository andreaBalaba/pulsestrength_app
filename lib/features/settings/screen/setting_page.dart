import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/authentication/screen/login_page.dart';
import 'package:pulsestrength/features/authentication/screen/privacy_policy.dart';
import 'package:pulsestrength/features/authentication/screen/terms_and_condition.dart';
import 'package:pulsestrength/features/settings/controller/setting_controller.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:simple_ruler_picker/simple_ruler_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController controller = Get.put(SettingsController());

  double get autoScale => Get.width / 400;

  bool isPrivacyExpanded = false;
  bool isEditInfoExpanded = false;
  double height = 170;

  double weight = 170;

  bool isKg = true; // to track the current unit
  double displayWeight = 0; // to store the displayed weight value

  bool isCm = true;
  double displayHeight = 0;


  @override
  void initState() {
    super.initState();
    controller.fetchUserData(); // Fetch user data on initialization
  }

  void _togglePrivacy() {
    setState(() {
      isPrivacyExpanded = !isPrivacyExpanded;
      if (isPrivacyExpanded) {
        isEditInfoExpanded =
        false; // Close Edit Information if Privacy is opened
      }
    });
  }

  void _toggleEditInfo() {
    setState(() {
      isEditInfoExpanded = !isEditInfoExpanded;
      if (isEditInfoExpanded) {
        isPrivacyExpanded =
        false; // Close Privacy if Edit Information is opened
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.pBGWhiteColor,
        title: ReusableText(
          text: 'Settings',
          size: 30 * autoScale,
          fontWeight: FontWeight.w500,
          color: AppColors.pGrey800Color,
        ),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: ReusableText(
              text: 'Back',
              size: 18 * autoScale,
              color: AppColors.pGrey800Color,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0 * autoScale),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            // Privacy Dropdown
            ListTile(
              title: ReusableText(
                text: "Privacy",
                size: 20 * autoScale,
                fontWeight: FontWeight.w600,
                color: AppColors.pBlack87Color,
              ),
              trailing: Icon(
                isPrivacyExpanded
                    ? Icons.keyboard_arrow_down_outlined
                    : Icons.arrow_forward_ios,
                size: 18 * autoScale,
                color: AppColors.pGreyColor,
              ),
              onTap: _togglePrivacy,
            ),
            if (isPrivacyExpanded) ...[
              ListTile(
                title: ReusableText(
                  text: "Privacy Policy",
                  size: 18 * autoScale,
                  fontWeight: FontWeight.w400,
                  color: AppColors.pBlack87Color,
                ),
                onTap: () {
                  Get.to(() => const PrivacyPolicyPage());
                },
              ),
              ListTile(
                title: ReusableText(
                  text: "Terms and Conditions",
                  size: 18 * autoScale,
                  fontWeight: FontWeight.w400,
                  color: AppColors.pBlack87Color,
                ),
                onTap: () {
                  Get.to(() => const TermsAndConditionsPage());
                },
              ),
            ],
            Divider(thickness: 1 * autoScale, color: AppColors.pBlackColor),

            // Account Section
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0 * autoScale),
              child: ReusableText(
                text: "Account",
                size: 18 * autoScale,
                fontWeight: FontWeight.w600,
                color: AppColors.pGreyColor,
              ),
            ),

            ListTile(
              title: ReusableText(
                text: "Edit information",
                size: 20 * autoScale,
                fontWeight: FontWeight.w600,
                color: AppColors.pBlack87Color,
              ),
              trailing: Icon(
                isEditInfoExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.arrow_forward_ios,
                size: 18 * autoScale,
                color: AppColors.pGreyColor,
              ),
              onTap: _toggleEditInfo,
            ),
            if (isEditInfoExpanded) ...[
              GestureDetector(
                onTap: _showHeightBottomSheet,
                child: _buildAccountInfo("Height", Obx(
                  () => ReusableText(
                    text: '${controller.height.value} cm',
                    size: 18 * autoScale,
                    color: AppColors.pOrangeColor,
                  ),
                ), AppColors.pOrangeColor),
              ),
              GestureDetector(
                onTap: () {
                  _showWeightBottomSheet();
                },
                child: _buildAccountInfo("Weight", Obx(
                  () => ReusableText(
                    text: '${controller.weight.value} kg',
                    size: 18 * autoScale,
                    color: AppColors.pOrangeColor,
                  ),
                ), AppColors.pOrangeColor),
              ),
              GestureDetector(
                onTap: () {
                  _showEditAgeDialog();
                },
                child: _buildAccountInfo("Age", Obx(
                  () => ReusableText(
                    text: '${controller.age.value}',
                    size: 18 * autoScale,
                    color: AppColors.pOrangeColor,
                  ),
                ), AppColors.pOrangeColor),
              ),
              _buildGenderSelection(),
            ],
            Divider(thickness: 1 * autoScale, color: AppColors.pBlackColor),

            const SizedBox(height: 60),

            // Log Out Button
            ElevatedButton(
              onPressed: () async {
                bool? shouldLogOut = await Get.dialog<bool>(AlertDialog(
                  backgroundColor: AppColors.pBGWhiteColor,
                  title: ReusableText(
                    text: "Confirmation",
                    size: 18 * autoScale,
                    fontWeight: FontWeight.bold,
                  ),
                  content: ReusableText(
                    text: "Are you sure you want to log out?",
                    size: 16 * autoScale,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: ReusableText(
                        text: "Cancel",
                        color: AppColors.pSOrangeColor,
                        size: 16 * autoScale,
                      ),
                    ),
                    TextButton(
                      onPressed: ()  => Get.back(result: true),
                      child: ReusableText(
                        text: "Log out",
                        color: AppColors.pSOrangeColor,
                        size: 16 * autoScale,
                      ),
                    ),
                  ],
                ));

                if (shouldLogOut == true) {
                  try {
                    await controller.signOut();
                    Get.offAll(() => const LogInPage());
                  }catch (e) {
                    // Show error if logout fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Logout failed: ${e.toString()}")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pSOrangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * autoScale),
                ),
              ),
              child: ReusableText(
                text: 'Log out',
                size: 18 * autoScale,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildAccountInfo(String title, Widget value, Color valueColor) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 6 * autoScale, horizontal: 16.0 * autoScale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ReusableText(
            text: title,
            size: 18 * autoScale,
            color: AppColors.pBlack87Color,
            fontWeight: FontWeight.w600,
          ),
          value,
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 6 * autoScale, horizontal: 16.0 * autoScale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ReusableText(
            text: "Gender",
            size: 18 * autoScale,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          SizedBox(height: 10 * autoScale),
          Obx(() => AbsorbPointer( // Disables user interaction
            absorbing: false, // Set to true to disable
            child: FlutterToggleTab(
              width: 40 * autoScale,
              borderRadius: 5 * autoScale,
              height: 30 * autoScale,
              selectedIndex: controller.selectedGender.value == "Male" ? 0 : 1,
              selectedBackgroundColors: const [AppColors.pOrangeColor],
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 16 * autoScale,
                fontWeight: FontWeight.w500,
              ),
              unSelectedTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16 * autoScale,
                fontWeight: FontWeight.w400,
              ),
              labels: const ["Male", "Female"],
              selectedLabelIndex: (index) {
                String selected = index == 0 ? "Male" : "Female";
                controller.selectGender(selected);
                },
            ),
          )),
        ],
      ),
    );
  }

  void _showHeightBottomSheet() {
    showModalBottomSheet(
      backgroundColor: AppColors.pBGWhiteColor,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20 * autoScale)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20 * autoScale,
            left: 16 * autoScale,
            right: 16 * autoScale,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildHeightDialogContent(),
        );
      },
    );
  }

  Widget _buildHeightDialogContent() {
    height = controller.height.value.toDouble();
    displayHeight = isCm ? height : (height * 0.0328084 * 12);

    return StatefulBuilder(builder: (context, setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ReusableText(
                text: "Height",
                fontWeight: FontWeight.bold,
                size: 28 * autoScale,
              ),
              FlutterToggleTab(
                width: 23 * autoScale,
                borderRadius: 20 * autoScale,
                height: 25 * autoScale,
                selectedIndex: isCm ? 0 : 1,
                selectedBackgroundColors: const [AppColors.pBGWhiteColor],
                selectedTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14 * autoScale,
                  fontWeight: FontWeight.w500,
                ),
                unSelectedTextStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14 * autoScale,
                  fontWeight: FontWeight.w400,
                ),
                labels: const ["cm", "ft"],
                selectedLabelIndex: (index) {
                  setState(() {
                    isCm = index == 0;
                    displayHeight = isCm ? height : (height * 0.0328084 * 12);
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20 * autoScale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ReusableText(
                text: isCm
                    ? '${displayHeight.toInt()}'
                    : '${(displayHeight/12).floor()}\'${(displayHeight%12).round()}"',
                size: 32 * autoScale,
                fontWeight: FontWeight.bold,
                color: AppColors.pOrangeColor,
              ),
              SizedBox(width: 5 * autoScale),
              ReusableText(
                text: isCm ? 'cm' : 'ft',
                size: 18 * autoScale,
              ),
            ],
          ),
          SizedBox(height: 20 * autoScale),
          Container(
            height: 180 * autoScale,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15 * autoScale),
            ),
            child: Column(
              children: [
                SizedBox(height: 20 * autoScale),
                SimpleRulerPicker(
                  key: ValueKey(isCm),
                  minValue: 100,
                  maxValue: 230,
                  initialValue: height.toInt(),
                  onValueChanged: (value) {
                    setState(() {
                      height = value.toDouble();
                      displayHeight = isCm
                          ? height
                          : (height * 0.393701);
                    });
                  },
                  scaleLabelSize: 14 * autoScale,
                  scaleBottomPadding: 8,
                  scaleItemWidth: 12,
                  longLineHeight: 30,
                  shortLineHeight: 15,
                  lineColor: AppColors.pBlack87Color,
                  selectedColor: AppColors.pOrangeColor,
                  labelColor: AppColors.pOrangeColor,
                  lineStroke: 2 * autoScale,
                  height: 100 * autoScale,
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * autoScale),
          ElevatedButton(
            onPressed: () async {
              // No conversion needed since ruler and height are always in cm
              final heightInCm = height.toStringAsFixed(0);
              controller.updateHeight(int.parse(heightInCm));
              Navigator.pop(context);
              
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pOrangeColor,
              minimumSize: Size(200 * autoScale, 50 * autoScale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * autoScale),
              ),
            ),
            child: ReusableText(
              text: 'Save',
              size: 18 * autoScale,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20 * autoScale),
        ],
      );
    });
  }

  void _showWeightBottomSheet() {
    showModalBottomSheet(
      backgroundColor: AppColors.pBGWhiteColor,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20 * autoScale)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20 * autoScale,
            left: 16 * autoScale,
            right: 16 * autoScale,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildWeightDialogContent(),
        );
      },
    );
  }

  Widget _buildWeightDialogContent() {
    // Initialize displayWeight when bottom sheet opens
    weight = controller.weight.value.toDouble();
    displayWeight = isKg ? weight : (weight * 2.20462);

    return StatefulBuilder(builder: (context, setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ReusableText(
                text: "Weight",
                fontWeight: FontWeight.bold,
                size: 28 * autoScale,
              ),
              SizedBox(width: 10 * autoScale),
              FlutterToggleTab(
                width: 23 * autoScale,
                borderRadius: 20 * autoScale,
                height: 25 * autoScale,
                selectedIndex: isKg ? 0 : 1,
                selectedBackgroundColors: const [AppColors.pBGWhiteColor],
                selectedTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14 * autoScale,
                  fontWeight: FontWeight.w500,
                ),
                unSelectedTextStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14 * autoScale,
                  fontWeight: FontWeight.w400,
                ),
                labels: const ["kg", "lbs"],
                selectedLabelIndex: (index) {
                  setState(() {
                    isKg = index == 0;
                    // Update display weight only
                    if (isKg) {
                      displayWeight = weight;
                    } else {
                      displayWeight = weight * 2.20462;
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20 * autoScale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ReusableText(
                text: '${displayWeight.toInt()}',
                size: 32 * autoScale,
                fontWeight: FontWeight.bold,
                color: AppColors.pOrangeColor,
              ),
              SizedBox(width: 5 * autoScale),
              ReusableText(
                  text: isKg ? 'kg' : 'lbs',
                  size: 18 * autoScale
              ),
            ],
          ),
          SizedBox(height: 20 * autoScale),
          Container(
            height: 180 * autoScale,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15 * autoScale),
            ),
            child: Column(
              children: [
                SizedBox(height: 20 * autoScale),
                SimpleRulerPicker(
                  key: ValueKey(isKg),
                  minValue: isKg ? 10 : 22,
                  maxValue: isKg ? 150 : 330,
                  initialValue: isKg 
                    ? weight.toInt().clamp(10, 150)
                    : (weight * 2.20462).toInt().clamp(22, 330),
                  onValueChanged: (value) {
                    setState(() {
                      weight = isKg ? value.toDouble() : (value / 2.20462);
                      displayWeight = isKg ? weight : (weight * 2.20462);
                    });
                  },
                  scaleLabelSize: 14 * autoScale,
                  scaleBottomPadding: 8,
                  scaleItemWidth: 12,
                  longLineHeight: 30,
                  shortLineHeight: 15,
                  lineColor: AppColors.pBlack87Color,
                  selectedColor: AppColors.pOrangeColor,
                  labelColor: AppColors.pOrangeColor,
                  lineStroke: 2 * autoScale,
                  height: 100 * autoScale,
                ),
                //SizedBox(height: 5 * autoScale)
              ],
            ),
          ),
          SizedBox(height: 20 * autoScale),
          ElevatedButton(
            onPressed: () async {
              // Convert back to kg if currently displaying in lbs
              final weightInKg = isKg ? weight : (displayWeight / 2.20462);
              controller.updateWeight(weightInKg.toInt());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pOrangeColor,
              minimumSize: Size(200 * autoScale, 50 * autoScale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * autoScale),
              ),
            ),
            child: ReusableText(
              text: 'Save',
              size: 18 * autoScale,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20 * autoScale),
        ],
      );
    });
  }

  void _showEditAgeDialog() {
    final TextEditingController ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: ReusableText(
            text: 'Please enter your age',
            size: 18 * autoScale,
            fontWeight: FontWeight.w600,
            color: AppColors.pBlackColor,
            align: TextAlign.center,
          ),
          content: TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter your age',
              hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16 * autoScale,
                  color: AppColors.pGreyColor
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: EdgeInsets.zero,
          actions: [
            SizedBox(height: 16 * autoScale),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: ReusableText(
                          text: 'Cancel',
                          size: 16 * autoScale,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (ageController.text.isNotEmpty) {
                          final age = int.tryParse(ageController.text.trim());
                          if (age != null) {
                             controller.updateAge(age);
                             Navigator.of(context).pop();
                          } else {
                              print('Invalid age value');
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ReusableText(
                          text: 'Save',
                          size: 16 * autoScale,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}