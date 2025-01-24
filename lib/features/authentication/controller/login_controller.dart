import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulsestrength/features/authentication/screen/login_page.dart';
import 'package:pulsestrength/features/home/screen/home_page.dart';
import 'package:pulsestrength/features/assessment/screen/get_started_page.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  late TextEditingController emailController;
  late TextEditingController passwordController;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _checkLoggedInStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!_isFormValid()) return;

    try {
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("No internet connection. Please check your connection and try again.");
      }

      isLoading.value = true;

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: "Failed to retrieve user details.",
        );
      }

      // Check email verification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        _showVerificationSuggestionDialog(user);
        await _auth.signOut();
        return;
      }

      await _updateIsVerifiedInDatabase(user.uid);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      final bool isDataCollected = await _isUserDataCollected(user);
      if (isDataCollected) {
        _navigateToHomePage();
      } else {
        Get.offAll(() => const GetStarted());
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS':
        case 'wrong-password':
        case 'user-not-found':
          errorMessage = 'Incorrect email or password.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred. Please try again later.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      clearForm();
      _navigateToLoginPage();
    } catch (e) {
      Get.snackbar(
        "Logout Error",
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _checkLoggedInStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      final User? user = _auth.currentUser;
      if (!isLoggedIn || user == null) {
        _navigateToLoginPage();
        return;
      }

      await user.reload();
      if (user.emailVerified) {
        final bool isDataCollected = await _isUserDataCollected(user);
        if (isDataCollected) {
          _navigateToHomePage();
        } else {
          Get.offAll(() => const GetStarted());
        }
      } else {
        await _auth.signOut();
        _navigateToLoginPage();
      }
    } catch (e) {
      print("Error in _checkLoggedInStatus: $e");
      Get.snackbar(
        "Error",
        "Failed to verify login status. Please try logging in again.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      _navigateToLoginPage();
    }
  }

  Future<bool> _isUserDataCollected(User user) async {
    try {
      final snapshot = await _databaseRef.child("users").child(user.uid).child("isDataCollected").get();
      return snapshot.exists && snapshot.value == true;
    } catch (e) {
      print("Error fetching user data: $e");
      return false;
    }
  }

  Future<void> _updateIsVerifiedInDatabase(String userId) async {
    try {
      await _databaseRef.child("users").child(userId).update({
        "isVerified": true,
      });
    } catch (e) {
      print("Error updating verification status in the database: $e");
    }
  }

  void _navigateToLoginPage() {
    if (Get.currentRoute != '/LogInPage') {
      Get.offAll(() => const LogInPage());
    }
  }

  void _navigateToHomePage() {
    if (Get.currentRoute != '/HomePage') {
      Get.offAll(() => const HomePage());
    }
  }

  bool _isFormValid() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both email and password.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }


  void clearForm() {
    emailController.clear();
    passwordController.clear();
  }
}


void _showVerificationSuggestionDialog(User user) {
  Get.dialog(
    Dialog(
      backgroundColor: AppColors.pBGWhiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(15),
              child: const Icon(
                Icons.mail_outline,
                color: Colors.orange,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const ReusableText(
              text: "Verify Your Email",
              size: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              align: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const ReusableText(
              text: "Your email is not verified. Please check your inbox for the verification link.",
              size: 16,
              color: AppColors.pBlack87Color,
              align: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pOrangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: const ReusableText(
                text: "OK",
                color: AppColors.pWhiteColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}


/*void _showGoogleAccountDialog() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.orange, size: 50),
            const SizedBox(height: 20),
            const ReusableText(
              text: "Google Account Found",
              size: 18,
              fontWeight: FontWeight.bold,
              align: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const ReusableText(
              text: "This email is linked to a Google account. Please use Google Sign-In to log in.",
              size: 16,
              align: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void _showSignUpDialog() {
  Get.dialog(
    Dialog(
      backgroundColor: AppColors.pBGWhiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.redAccent.shade100,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(15),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.pSOrangeColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const ReusableText(
              text: "Account Not Found",
              size: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.pSOrangeColor,
              align: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const ReusableText(
              text: "No user found with this email. Would you like to sign up?",
              size: 16,
              color: AppColors.pBlack87Color,
              align: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => const SignUpPage(), transition: Transition.noTransition);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pSOrangeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const ReusableText(text: "Sign Up", color: AppColors.pWhiteColor, size: 16),
                ),
                OutlinedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.pSOrangeColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const ReusableText(text: "Cancel", color: AppColors.pSOrangeColor, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}*/
