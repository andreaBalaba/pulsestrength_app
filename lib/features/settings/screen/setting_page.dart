import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/authentication/screen/login_page.dart';
import 'package:pulsestrength/features/settings/controller/setting_controller.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

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

            // Notification Switch
            Obx(() => Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildCustomSwitch(
                label: "Notification",
                value: controller.isNotificationEnabled.value,
                onToggle: controller.toggleNotification,
              ),
            )),
            Divider(thickness: 1 * autoScale, color: AppColors.pBlackColor),

            // Warm up Switch
            Obx(() => Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildCustomSwitch(
                label: "Warm up",
                value: controller.isWarmUpEnabled.value,
                onToggle: controller.toggleWarmUp,
              ),
            )),
            Divider(thickness: 1 * autoScale, color: AppColors.pBlackColor),

            // Stretching Switch
            Obx(() => Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildCustomSwitch(
                label: "Stretching",
                value: controller.isStretchingEnabled.value,
                onToggle: controller.toggleStretching,
              ),
            )),
            Divider(thickness: 1 * autoScale, color: AppColors.pBlackColor),

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
                  // Handle Privacy Policy tap
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
                  // Handle Terms and Conditions tap
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
              Obx(() => _buildAccountInfo(
                  "Height", "${controller.height.value} cm", AppColors.pOrangeColor)),
              Obx(() => _buildAccountInfo(
                  "Weight", "${controller.weight.value} kg", AppColors.pOrangeColor)),
              Obx(() =>
                  _buildAccountInfo("Age", "${controller.age.value}", AppColors.pOrangeColor)),
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

  Widget _buildCustomSwitch({
    required String label,
    required bool value,
    required Function(bool) onToggle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ReusableText(
          text: label,
          size: 20 * autoScale,
          fontWeight: FontWeight.w600,
        ),
        FlutterSwitch(
          width: 50.0 * autoScale,
          height: 30.0 * autoScale,
          toggleSize: 25.0 * autoScale,
          value: value,
          borderRadius: 20.0 * autoScale,
          padding: 2.0 * autoScale,
          activeColor: AppColors.pGreenColor,
          inactiveColor: AppColors.pMGreyColor,
          onToggle: onToggle,
        ),
      ],
    );
  }

  Widget _buildAccountInfo(String title, String value, Color valueColor) {
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
          ReusableText(
            text: value,
            size: 18 * autoScale,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
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
            absorbing: true, // Set to true to disable
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
}