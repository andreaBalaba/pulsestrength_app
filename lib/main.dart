import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulsestrength/features/splash/screen/splash_page.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await requestActivityRecognitionPermission();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Gemini.init(apiKey: GEMINI_KEY);
  runApp(const MyApp());
}

// Request activity recognition permission and show dialog if denied
Future<void> requestActivityRecognitionPermission() async {
  PermissionStatus status = await Permission.activityRecognition.request();

  if (status.isDenied) {
    // Show dialog if permission is denied
    Get.dialog(
      AlertDialog(
        title: const Text('Activity Recognition Permission'),
        content: const Text(
          'This app needs activity recognition permission to function correctly.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Deny'),
            onPressed: () {
              Get.back(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text('Settings'),
            onPressed: () {
              openAppSettings(); // Open app settings
              Get.back(); // Close the dialog
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PulseStrength',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.pWhiteColor),
      ),
      home: const SplashPage(),
    );
  }
}
