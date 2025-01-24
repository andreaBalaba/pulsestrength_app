import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pulsestrength/api/services/add_foods_data.dart';
import 'package:pulsestrength/features/assessment/screen/get_started_page.dart';
import 'package:pulsestrength/features/authentication/controller/login_controller.dart';
import 'package:pulsestrength/features/authentication/screen/login_page.dart';
import 'package:pulsestrength/features/home/screen/home_page.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var isLoading = false.obs;
  var isTermsAccepted = false.obs;
  var passwordsMatch = true.obs;


  SignUpController() {
    confirmPasswordController.addListener(() {
      if (confirmPasswordController.text.isEmpty) {
        passwordsMatch.value = true;
      } else {
        passwordsMatch.value = passwordController.text == confirmPasswordController.text;
      }
    });
  }

  Future<User?> signInOrSignUpWithGoogle({required Function(String) onPrompt}) async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        onPrompt("Google sign-in was canceled.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential googleUserCredential = await _auth.signInWithCredential(credential);
      final User? googleUserDetails = googleUserCredential.user;

      if (googleUserDetails == null) {
        onPrompt("Google sign-in failed. Please try again.");
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('lastPage', 'GetStarted');

      final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(googleUserDetails.email!);

      if (signInMethods.contains('password')) {
        await _linkGoogleToExistingAccount(credential, onPrompt);
      }

      final bool isNewUser = await _ensureUserDataInDatabase(googleUserDetails);
      addFoodData();

      final DatabaseReference userRef = _databaseRef.child("users").child(googleUserDetails.uid);
      final DataSnapshot snapshot = await userRef.get();
      final bool isDataCollected = snapshot.child("isDataCollected").value as bool? ?? false;

      if (isDataCollected) {
        Get.offAll(() => const HomePage());
      } else {
        Get.offAll(() => const GetStarted());
      }

      return googleUserDetails;
    } catch (e) {
      onPrompt("Google Sign-In/Sign-Up failed: ${e.toString()}");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _linkGoogleToExistingAccount(
      OAuthCredential credential, Function(String) onPrompt) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Link Google account to existing email/password account
        await currentUser.linkWithCredential(credential);
        onPrompt("Google account successfully linked to your existing email/password account.");
      }
    } catch (e) {
      onPrompt("Error linking Google account: ${e.toString()}");
      rethrow;
    }
  }

  Future<bool> _ensureUserDataInDatabase(User user) async {
    final DatabaseReference userRef = _databaseRef.child("users").child(user.uid);
    final DataSnapshot snapshot = await userRef.get();

    if (!snapshot.exists) {
      await _saveGoogleUserData(user);
          return true; // New user
    }
    return false; // Existing user
  }

  Future<void> _saveGoogleUserData(User user) async {
    try {
      await _databaseRef.child("users").child(user.uid).set({
        "username": user.displayName ?? "User",
        "email": user.email,
        "isVerified": true,
        "isDataCollected": false,
        "isCalculatorOnboarded": false,
        "created_at": DateTime.now().toIso8601String(),
      });
      print("Google user data saved successfully.");
    } catch (e) {
      print("Error saving Google user data: $e");
      rethrow;
    }
  }

  Future<void> verifyEmailIfNeeded(User user, Function(String) onPrompt) async {
    // Step 1: Check if the user's email is verified
    if (!user.emailVerified) {
      await user.sendEmailVerification();
      onPrompt("Email verification sent. Please verify your email.");
      // Optionally, navigate to a verification page or wait for confirmation
    } else {
      onPrompt("Email is already verified.");
    }
  }



  Future<void> signUp() async {
    if (_isFormValid()) {
      try {
        isLoading.value = true;

        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await userCredential.user!.sendEmailVerification();

        await _saveUserData(userCredential.user!.uid);
        addFoodData();

        Get.snackbar(
          "Verify Your Email",
          "A verification link has been sent to your email. Please verify to proceed.",
          backgroundColor: AppColors.pGreenColor,
          colorText: AppColors.pWhiteColor,
        );

        await _auth.signOut();

        final loginController = Get.find<LoginController>();
        loginController.clearForm();

        Get.offAll(() => const LogInPage());
      } catch (e) {
        _handleSignUpError(e);
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> _saveUserData(String userId) async {
    await _databaseRef.child("users").child(userId).set({
      "username": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "isVerified": false,
      "isDataCollected": false,
      "isCalculatorOnboarded": false,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  bool _isFormValid() {
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorSnackbar("Error", "Please fill out all fields.");
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      passwordsMatch.value = false;
      _showErrorSnackbar("Error", "Passwords do not match.");
      return false;
    }

    if (!isTermsAccepted.value) {
      _showErrorSnackbar("Error", "Please read and accept the Terms and Conditions and Privacy Policy.");
      return false;
    }

    return true;
  }

  void _handleSignUpError(dynamic error) {
    String errorMessage = "An unexpected error occurred. Please try again.";
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case "email-already-in-use":
          errorMessage = "This email is already registered. Please log in.";
          break;
        case "weak-password":
          errorMessage = "The password is too weak. Please choose a stronger password.";
          break;
        case "invalid-email":
          errorMessage = "The email address is invalid. Please enter a valid email.";
          break;
        default:
          errorMessage = error.message ?? errorMessage;
      }
    }
    _showErrorSnackbar("Sign-Up Error", errorMessage);
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent,
      colorText: AppColors.pWhiteColor,
    );
  }

  void clearForm() {
    emailController.clear();
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    isTermsAccepted.value = false;
    passwordsMatch.value = true;
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
