import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/authentication/controller/login_controller.dart';
import 'package:pulsestrength/features/authentication/controller/signup_controller.dart';
import 'package:pulsestrength/features/authentication/screen/signup_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final SignUpController googlecontroller = Get.put(SignUpController());
  final LoginController controller = Get.put(LoginController(), permanent: true);
  double get autoScale => Get.width / 360;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pWhiteColor,
      body: Stack(
        children: [
          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * autoScale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50 * autoScale),
                    _buildLogo(),
                    SizedBox(height: 50 * autoScale),
                    _buildTextField(
                      hintText: 'Email',
                      isPasswordField: false,
                      controller: controller.emailController,
                    ),
                    SizedBox(height: 25 * autoScale),
                    _buildTextField(
                      hintText: 'Password',
                      isPasswordField: true,
                      controller: controller.passwordController,
                    ),
                    SizedBox(height: 20 * autoScale),
                    _buildContinueDivider(),
                    SizedBox(height: 20 * autoScale),
                    _buildGoogleButton(),
                    SizedBox(height: 30 * autoScale),
                    _buildSignUpText(),
                    SizedBox(height: 30 * autoScale),
                    _buildLoginButton(),
                    SizedBox(height: 30 * autoScale),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.pGreenColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 180 * autoScale,
      height: 180 * 0.75 * autoScale,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.asset(ImageAssets.pLogo),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required bool isPasswordField,
    required TextEditingController controller,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
  }) {
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
        controller: controller,
        focusNode: focusNode,
        obscureText: isPasswordField && !_isPasswordVisible,
        style: TextStyle(
          color: AppColors.pBlackColor,
          fontFamily: 'Poppins',
          fontSize: 14 * autoScale,
        ),
        cursorColor: AppColors.pGrey800Color,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: isPasswordField ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (value) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15 * autoScale),
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.pDarkGreyColor,
            fontFamily: 'Poppins',
            fontSize: 14 * autoScale,
          ),
          suffixIcon: isPasswordField
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.pGrey800Color,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildContinueDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, color: AppColors.pBlackColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * autoScale),
          child: ReusableText(
            text: "Continue with",
            size: 14 * autoScale,
          ),
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
          setState(() => _isLoading = true); // Show loading overlay
          await googlecontroller.signInOrSignUpWithGoogle(onPrompt: (message) {
            Get.snackbar("Google Auth", message);
          });
          setState(() => _isLoading = false); // Hide loading overlay
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

  Widget _buildSignUpText() {
    return RichText(
      text: TextSpan(
        text: "Don’t have an account yet? ",
        style: TextStyle(
          color: AppColors.pDarkGreyColor,
          fontSize: 12 * autoScale,
          fontFamily: 'Poppins',
        ),
        children: [
          TextSpan(
            text: "Sign Up",
            style: TextStyle(
              color: AppColors.pSOrangeColor,
              fontSize: 12 * autoScale,
              fontFamily: 'Poppins',
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                googlecontroller.clearForm();
                Get.to(() => const SignUpPage());
              },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: 150 * autoScale,
      height: 50 * autoScale,
      child: ElevatedButton(
        onPressed: () async {
          setState(() => _isLoading = true); // Show loading overlay
          await controller.login();
          setState(() => _isLoading = false); // Hide loading overlay
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pTFColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18 * autoScale)),
        ),
        child: ReusableText(
          text: "Log in",
          color: AppColors.pDarkGreyColor,
          fontWeight: FontWeight.w500,
          size: 14 * autoScale,
        ),
      ),
    );
  }
}
