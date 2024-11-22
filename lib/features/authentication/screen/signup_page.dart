import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/authentication/controller/login_controller.dart';
import 'package:pulsestrength/features/authentication/controller/signup_controller.dart';
import 'package:pulsestrength/features/authentication/screen/login_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SignUpController controller = Get.put(SignUpController());
  double autoScale = Get.width / 360;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * autoScale),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50 * autoScale),
                ReusableText(
                  text: "SIGN UP",
                  size: 28 * autoScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pDarkGreyColor,
                ),
                const SizedBox(height: 30),
                _buildTextField("Name", controller.usernameController, false, false, () {}),
                SizedBox(height: 25 * autoScale),
                _buildTextField("Email Address", controller.emailController, false, false, () {}),
                SizedBox(height: 25 * autoScale),
                _buildTextField("Password", controller.passwordController, true, isPasswordVisible, () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                }),
                SizedBox(height: 25 * autoScale),
                _buildTextField("Confirm Password", controller.confirmPasswordController, true, isConfirmPasswordVisible, () {
                  setState(() {
                    isConfirmPasswordVisible = !isConfirmPasswordVisible;
                  });
                }),


                Obx(() {
                  return Column(
                    children: [
                      if (!controller.passwordsMatch.value)
                        Padding(
                          padding: EdgeInsets.only(top: 8 * autoScale),
                          child: ReusableText(
                            text: 'Passwords do not match',
                            color: AppColors.pSOrangeColor,
                            size: 12 * autoScale,
                          ),
                        )
                      else if (controller.confirmPasswordController.text.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8 * autoScale),
                          child: ReusableText(
                            text: 'Passwords match',
                            color: AppColors.pGreenColor,
                            size: 12 * autoScale,
                          ),
                        ),
                    ],
                  );
                }),
                SizedBox(height: 20 * autoScale),
                _buildDivider("Continue with"),
                SizedBox(height: 20 * autoScale),
                _buildGoogleButton(),
                SizedBox(height: 25 * autoScale),
                _buildTermsCheckbox(),
                SizedBox(height: 30 * autoScale),
                _buildLoginText(),
                SizedBox(height: 30 * autoScale),

                // Show loading indicator or Sign Up button
                Obx(() {
                  return controller.isLoading.value
                      ? const CircularProgressIndicator(color: AppColors.pGreenColor)
                      : _buildSignUpButton();
                }),
                SizedBox(height: 40 * autoScale),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hintText, TextEditingController textController, bool isPasswordField, bool isPasswordVisible, Function toggleVisibility) {
    return Container(
      height: 50 * autoScale,
      decoration: BoxDecoration(
        color: AppColors.pTFColor,
        borderRadius: BorderRadius.circular(18.0 * autoScale),
        boxShadow: [
          BoxShadow(
            color: AppColors.pGrey400Color,
            spreadRadius: -1,
            blurRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        obscureText: isPasswordField && !isPasswordVisible,
        textInputAction: TextInputAction.next,
        cursorColor: AppColors.pGrey800Color,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15 * autoScale),
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.pDarkGreyColor,
            fontSize: 14 * autoScale,
            fontFamily: 'Poppins',
          ),
          suffixIcon: isPasswordField
              ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.pGrey800Color,
            ),
            onPressed: () => toggleVisibility(),
          )
              : null,
        ),
      ),
    );
  }


  Widget _buildDivider(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, color: AppColors.pBlackColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * autoScale),
          child: ReusableText(text: text, size: 12 * autoScale),
        ),
        const Expanded(child: Divider(thickness: 1, color: AppColors.pBlackColor)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50 * autoScale,
      child: ElevatedButton.icon(
        onPressed: () async {
          await controller.signInOrSignUpWithGoogle(onPrompt: (message) {
            Get.snackbar("Google Auth", message);
          });
        },
        icon: Image.asset(
          IconAssets.pGoogleIcon,
          height: 33 * autoScale,
          width: 33 * autoScale,
        ),
        label: ReusableText(
          text: "Google",
          color: AppColors.pBlackColor,
          fontWeight: FontWeight.w500,
          size: 14 * autoScale,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pTFColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18 * autoScale),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Obx(() {
          return Checkbox(
            value: controller.isTermsAccepted.value,
            onChanged: (value) {
              controller.isTermsAccepted.value = value!;
            },
            activeColor: AppColors.pGreenColor,
          );
        }),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "I agree to the ",
              style: TextStyle(
                  color: AppColors.pDarkGreyColor,
                  fontSize: 12 * autoScale,
                  fontFamily: 'Poppins'),
              children: [
                TextSpan(
                  text: "Terms and Conditions",
                  style: const TextStyle(
                    color: AppColors.pSOrangeColor,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Add Terms and Conditions logic
                    },
                ),
                const TextSpan(
                  text: " and ",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                TextSpan(
                  text: "Privacy Policy",
                  style: const TextStyle(
                    color: AppColors.pSOrangeColor,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Add Privacy Policy logic
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginText() {
    return RichText(
      text: TextSpan(
        text: "Already have an account? ",
        style: TextStyle(
            color: AppColors.pDarkGreyColor,
            fontSize: 12 * autoScale,
            fontFamily: 'Poppins'),
        children: [
          TextSpan(
            text: "Login",
            style: const TextStyle(
              color: AppColors.pSOrangeColor,
              fontFamily: 'Poppins',
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {

                final loginController = Get.find<LoginController>();
                loginController.clearForm();

                Get.to(() => const LogInPage());
              },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: 150 * autoScale,
      height: 50 * autoScale,
      child: ElevatedButton(
        onPressed: controller.signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pTFColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18 * autoScale),
          ),
        ),
        child: ReusableText(
          text: "Sign Up",
          color: AppColors.pDarkGreyColor,
          fontWeight: FontWeight.w500,
          size: 14 * autoScale,
        ),
      ),
    );
  }
}
