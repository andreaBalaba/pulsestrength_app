import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_button.dart';
import 'package:pulsestrength/utils/reusable_text.dart';


class CoolDownDetailPage extends StatefulWidget {
  final dynamic data;
  final List cooldowns;
  final int currentIndex;

  const CoolDownDetailPage({
    super.key, 
    required this.data, 
    required this.cooldowns,
    required this.currentIndex,
  });

  @override
  State<CoolDownDetailPage> createState() => _CoolDownDetailPageState();
}

class _CoolDownDetailPageState extends State<CoolDownDetailPage> {
  bool isDone = false;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool hasStarted = false;
  bool isPaused = false;
  bool isRinging = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTimerDoneSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
      print('Playing sound');
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _startTimer(int minutes) {
    setState(() {
      _remainingSeconds = minutes * 60;
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
        setState(() {
          isDone = true;
          hasStarted = false;
          isPaused = false;
          isRinging = true;
        });
        _playTimerDoneSound();
      }
    });
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

  void _goToNextCoolDown() {
    _audioPlayer.stop();
    Get.back(result: isDone ? 'completed' : 'skipped');
  }

  String _getButtonText() {
    if (isRinging) {
      return 'Stop';
    }
    if (isDone) {
      return 'Finish';
    }
    if (!hasStarted) {
      return 'Start';
    }
    if (isPaused) {
      return 'Resume';
    }
    return 'Pause';
  }

  void _handleButtonPress() {
    if (isRinging) {
      _audioPlayer.stop();
      setState(() {
        isRinging = false;
      });
      return;
    }

    if (isDone) {
      _goToNextCoolDown();
      return;
    }

    if (!hasStarted) {
      setState(() {
        hasStarted = true;
      });
      _startTimer(widget.data['minutes'] ?? 5);
    } else if (isPaused) {
      _resumeTimer();
    } else {
      _pauseTimer();
    }
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
          text: 'Cool Down',
          fontWeight: FontWeight.bold,
          size: 20,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isDone = false;
              });
              _goToNextCoolDown();
            },
            child: const ReusableText(text: 'Skip'),
          ),
        ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ReusableText(
                      text: widget.data['activity'],
                      fontWeight: FontWeight.w600,
                      size: 24,
                      color: AppColors.pBlack87Color,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      align: TextAlign.center,
                    ),
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
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
                          text: 'Great, you can proceed now!',
                          fontWeight: FontWeight.w600,
                          size: 18,
                          color: AppColors.pBlack87Color,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          align: TextAlign.center,
                        ),
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
            onPressed: _handleButtonPress,
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