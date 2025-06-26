import 'dart:async'; // Import for Timer

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_button.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';



class DailyTaskPage extends StatefulWidget {
  dynamic data;
  int? calories;

  DailyTaskPage({super.key, required this.data, this.calories});

  @override
  State<DailyTaskPage> createState() => _DailyTaskPageState();
}

class _DailyTaskPageState extends State<DailyTaskPage> {
  bool isDone = false;
  Timer? _timer; // Timer object
  int _remainingSeconds = 0; // Remaining seconds for the countdown

  bool hasStarted = false;
  bool isPaused = false;
  bool isRinging = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Add new variables for set management
  int currentSet = 1;
  int totalSets = 1;
  int minutesPerSet = 0;

  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initAudio();
    // Initialize set information and calculate minutes per set
    totalSets = widget.data['sets'] ?? 1;
    minutesPerSet = ((widget.data['minutes'] ?? 1) / totalSets).ceil();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer(int minutes) {
    setState(() {
      _remainingSeconds = minutes * 60;
      hasStarted = true;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _handleSetCompletion();
      }
    });
  }

  void _handleSetCompletion() {
    if (currentSet < totalSets) {
      // More sets to go
      setState(() {
        isDone = false;
        hasStarted = false;
        isPaused = false;
        isRinging = true;
        currentSet++;
      });
      _playTimerDoneSound();
    } else {
      // All sets completed
      setState(() {
        isDone = true;
        hasStarted = false;
        isPaused = false;
        isRinging = true;
      });
      _playTimerDoneSound();
    }
  }

  Future<void> _playTimerDoneSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      isPaused = false;
    });
    _startCountdown();
  }

  String _getButtonText() {
    if (isRinging) return 'Stop';
    if (!hasStarted) return 'Start Set $currentSet';
    if (isPaused) return 'Resume Set $currentSet';
    if (isDone) return 'Finish';
    return 'Pause Set $currentSet';
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 360;
    double screenHeight = Get.height;
    double screenWidth = Get.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.pBGWhiteColor,
        surfaceTintColor: AppColors.pNoColor,
        title: const ReusableText(
          text: 'Workout',
          fontWeight: FontWeight.bold,
          size: 20,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.pNoColor,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.data['image'],
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ReusableText(
                    text: widget.data['exercise'],
                    fontWeight: FontWeight.w600,
                    size: 24,
                    color: AppColors.pBlack87Color,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ReusableText(
                    text: 'Set $currentSet of $totalSets - ${widget.data['reps']} reps',
                    fontWeight: FontWeight.w500,
                    size: 18,
                    color: AppColors.pGreenColor,
                  ),
                  const SizedBox(height: 10),
                  ReusableText(
                    text: '$minutesPerSet minutes per set',
                    fontWeight: FontWeight.w500,
                    size: 16,
                    color: AppColors.pGreyColor,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pNoColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.green,
                          size: 40,
                        ),
                        const SizedBox(width: 10),
                        ReusableText(
                          text: _formatTime(_remainingSeconds),
                          fontWeight: FontWeight.w600,
                          size: 32,
                          color: AppColors.pGreenColor,
                        ),
                      ],
                    ),
                  ),
                  if (isDone)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pGreen38Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const ReusableText(
                          text: 'Workout completed!',
                          fontWeight: FontWeight.w600,
                          size: 18,
                          color: AppColors.pBlack87Color,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  if (isRinging && !isDone)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pGreen38Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ReusableText(
                          text: 'Set $currentSet completed! Ready for next set?',
                          fontWeight: FontWeight.w600,
                          size: 18,
                          color: AppColors.pBlack87Color,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pNoColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [ 
                        const ReusableText(
                          text: 'Calories burned : ',
                          fontWeight: FontWeight.bold,
                          size: 18,
                        ),const SizedBox(width: 8),
                        Image.asset(
                          IconAssets.pFireIcon,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        ReusableText(
                          text: '${widget.data['calories_burned'] ?? 0}',
                          fontWeight: FontWeight.w600,
                          size: 18,
                          color: AppColors.pDarkOrangeColor,
                        ),
                        const ReusableText(
                          text: ' kcal',
                          fontWeight: FontWeight.w500,
                          size: 18,
                          color: AppColors.pDarkOrangeColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 20.0 * autoScale,
          right: 20.0 * autoScale,
          top: 5.0 * autoScale,
          bottom: 40.0 * autoScale,
        ),
        child: SizedBox(
          height: screenHeight * 0.065,
          width: double.infinity,
          child: ReusableButton(
            text: _getButtonText(),
            onPressed: () async {
              if (isRinging) {
                _audioPlayer.stop();
                setState(() {
                  isRinging = false;
                });
                return;
              }

              if (isDone) {
                _audioPlayer.stop();
                // Store completed task in SharedPreferences only
                final prefs = await SharedPreferences.getInstance();
                final today = DateTime.now().toIso8601String().split('T')[0];
                final completedTasks = prefs.getStringList('completed_tasks_$today') ?? [];
                if (!completedTasks.contains(widget.data['exercise'])) {
                  completedTasks.add(widget.data['exercise']);
                  await prefs.setStringList('completed_tasks_$today', completedTasks);

                  // Update Realtime Database stats
                  final databaseRef = FirebaseDatabase.instance.ref();
                  final weeklyRef = databaseRef.child('users/${FirebaseAuth.instance.currentUser!.uid}/Weekly');
                  final weekdayRef = weeklyRef.child(DateTime.now().weekday.toString());

                  await weekdayRef.update({
                    'workouts': ServerValue.increment(1),
                    'calories': ServerValue.increment(widget.data['calories_burned'] ?? widget.calories),
                    'mins': ServerValue.increment(widget.data['minutes']),
                  });

                  await weeklyRef.child('completed_tasks').once().then((snapshot) {
                    List<dynamic> completedTasks = (snapshot.snapshot.value ?? []) as List<dynamic>;
                    if (!completedTasks.contains(widget.data['exercise'])) {
                      completedTasks.add(widget.data['exercise']);
                      weeklyRef.child('completed_tasks').set(completedTasks);
                    }
                  });
                }
                Get.back(result: 'completed');
                return;
              }

              if (!hasStarted) {
                _speak('Starting set $currentSet of $totalSets with ${widget.data['reps']} reps');
                _startTimer(minutesPerSet);
              } else if (isPaused) {
                _resumeTimer();
              } else {
                _pauseTimer();
              }
            },
            color: AppColors.pGreenColor,
            fontColor: AppColors.pWhiteColor,
            borderRadius: 30.0 * autoScale,
            size: 18 * autoScale,
            weight: FontWeight.w600,
            removePadding: true,
          ),
        ),
      ),
    );
  }
}
