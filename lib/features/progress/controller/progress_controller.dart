import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ProgressController extends GetxController {
  final ScrollController scrollController = ScrollController();

  var stepCount = 0.obs;

  Stream<StepCount>? _stepCountStream;

  @override
  void onInit() {
    super.onInit();
    _initStepCounter();
  }

  void _initStepCounter() {
    try {
      // Get the start of the current day
      DateTime startOfDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      // Listen to the step count stream
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream?.listen(
        (StepCount stepCountData) {
          // Calculate the steps taken today
          int stepsToday = stepCountData.steps - stepCount.value;

          // Update the step count with the steps taken today
          stepCount.value = stepsToday;

          // Save the current step count to Realtime Database
          FirebaseDatabase.instance
              .ref('users/${FirebaseAuth.instance.currentUser!.uid}/Weekly/${DateTime.now().weekday.toString()}')
              .update({
            'steps': stepsToday,
          });
        },
        onError: (error) {
          print("Step Count Error: $error");
        },
        cancelOnError: true,
      );

      // Reset the step count at the start of each day
      Timer.periodic(Duration(days: 1), (Timer timer) {
        DateTime now = DateTime.now();
        if (now.day != startOfDay.day) {
          startOfDay = DateTime(now.year, now.month, now.day);
          stepCount.value = 0;
        }
      });
    } catch (e) {
      print("Error initializing step counter: $e");
    }
  }

  @override
  void onClose() {
    // Dispose of the stream if necessary
    _stepCountStream = null;
    super.onClose();
  }
}
