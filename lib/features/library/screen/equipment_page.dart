import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_button.dart';
import 'package:pulsestrength/utils/reusable_text.dart';
import 'package:url_launcher/url_launcher_string.dart';


class EquipmentPage extends StatefulWidget {
  String data;
  bool? isName;

  EquipmentPage({super.key, required this.data, this.isName = false});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  // Timer and set management variables
  Timer? _timer;
  int _remainingSeconds = 0;
  bool hasStarted = false;
  bool isPaused = false;
  bool isRinging = false;
  bool isDone = false;
  int currentSet = 1;
  int totalSets = 1;
  int minutesPerSet = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    getData();
    _initAudio();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setSource(AssetSource('sounds/beep.mp3'));
  }

  dynamic equipmentData;
  bool hasLoaded = false;
  String selectedItem = 'Beginner';
  final List<String> items = ['Beginner', 'Intermediate', 'Advanced'];

  getData() async {
    String jsonString =
        await rootBundle.loadString('lib/api/Gym-equipments-Datas.json');

    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    List equipments = jsonData['equipment'];

    setState(() {
      equipmentData = equipments.where(
        (element) {
          return element['name'] == widget.data;
        },
      ).first;

      // Initialize set information
      int i = selectedItem == 'Beginner'
          ? 0
          : selectedItem == 'Intermediate'
              ? 1
              : 2;
      
      // Get total minutes and sets from the workout data
      int totalMinutes = equipmentData['levels'][i]['workouts'].first['minutes'] ?? 1;
      totalSets = equipmentData['levels'][i]['workouts'].first['sets'] ?? 1;

      // Calculate minutes per set, rounding up to ensure full coverage
      minutesPerSet = (totalMinutes / totalSets).ceil();

      hasLoaded = true;
    });
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
    setState(() {
      currentSet++;
      isDone = false; // Not done yet.
      hasStarted = false;
      isPaused = false;
      isRinging = true;
    });
    _playTimerDoneSound();
  } else {
    setState(() {
      isDone = true; // All sets completed.
      hasStarted = false;
      isPaused = false;
      isRinging = true;
    });
    _playTimerDoneSound();
  }
  debugPrint('Set Completion: isDone=$isDone, currentSet=$currentSet, totalSets=$totalSets');
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

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getButtonText() {
  if (isRinging) return 'Stop';
  if (isDone) return 'Restart'; // After all sets are done, show "Restart."
  if (!hasStarted) return 'Start Set $currentSet';
  if (isPaused) return 'Resume Set $currentSet';
  return 'Pause Set $currentSet';
}


  int _getSelectedLevelIndex() {
    return selectedItem == 'Beginner'
        ? 0
        : selectedItem == 'Intermediate'
            ? 1
            : 2;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = Get.height;


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.pBGWhiteColor,
        surfaceTintColor: AppColors.pNoColor,
        title: ReusableText(
                        text: widget.data,
                        fontWeight: FontWeight.w600,
                        size: 18,
                        color: AppColors.pBlack87Color,
                        decoration: null,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.pBGWhiteColor,
        child: const Icon(
          Icons.volume_up,
          size: 20,
          color: AppColors.pBlackColor,
        ),
        onPressed: () async {
          int i = _getSelectedLevelIndex();
          await flutterTts.setVolume(1.0);

          await flutterTts.speak(
              'Step by step instruction for ${equipmentData['levels'][i]['level']} Level, ${equipmentData['levels'][i]['step_by_step_instructions']}');
        },
      ),
      body: hasLoaded
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: DropdownButton<String>(
                          value: selectedItem,
                          hint: const Text('Select Level'),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: items.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Container(
                                alignment: Alignment.center,
                                child: ReusableText(
                                  text: item,
                                  align: TextAlign.center,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            // Update the selected item
                            setState(() {
                              selectedItem = value!;
                              // Reinitialize set information when level changes
                              int i = _getSelectedLevelIndex();
                              
                              // Get total minutes and sets from the workout data
                              int totalMinutes = equipmentData['levels'][i]['workouts'].first['minutes'] ?? 1;
                              totalSets = equipmentData['levels'][i]['workouts'].first['sets'] ?? 1;

                              // Calculate minutes per set, rounding up to ensure full coverage
                              minutesPerSet = (totalMinutes / totalSets).ceil();
                              
                              // Reset all timer-related states
                              _timer?.cancel();
                              _remainingSeconds = 0;
                              hasStarted = false;
                              isPaused = false;
                              isRinging = false;
                              isDone = false;
                              currentSet = 1;
                            });
                          },
                        ),
                      ),
                      Builder(builder: (context) {
                        int i = _getSelectedLevelIndex();
                        return SizedBox(
                          width: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 350.0,
                                height: 250.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(equipmentData['levels']
                                            [i]['workouts']
                                        .first['img']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ReusableText(
                                text: 'Set $currentSet of $totalSets - ${equipmentData['levels'][i]['workouts'].first['reps']} reps',
                                fontWeight: FontWeight.w500,
                                size: 18,
                                color: AppColors.pGreenColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
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
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 300,
                                      child: Column(
                                        children: [
                                          const ReusableText(
                                            text: 'Overview',
                                            fontWeight: FontWeight.w600,
                                            size: 18,
                                            color: AppColors.pBlack87Color,
                                            decoration: null,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            align: TextAlign.center,
                                          ),
                                          const SizedBox(height: 30),
                                          ReusableText(
                                            text: equipmentData['levels'][i]['overview'],
                                            fontWeight: FontWeight.w200,
                                            size: 12,
                                            color: AppColors.pBlack87Color,
                                            decoration: null,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 20,
                                            align: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Column(
                                        children: [
                                          const ReusableText(
                                            text: 'Basic Alternatives',
                                            fontWeight: FontWeight.w600,
                                            size: 18,
                                            color: AppColors.pBlack87Color,
                                            decoration: null,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            align: TextAlign.center,
                                          ),
                                          const SizedBox(height: 30),
                                          ReusableText(
                                            text: equipmentData['levels'][i]['basics_and_alternatives']['alternative'],
                                            fontWeight: FontWeight.w200,
                                            size: 12,
                                            color: AppColors.pBlack87Color,
                                            decoration: null,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 20,
                                            align: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const ReusableText(
                                            text: 'Correct Execution',
                                            fontWeight: FontWeight.w600,
                                            size: 18,
                                            color: AppColors.pBlack87Color,
                                            decoration: null,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            align: TextAlign.center,
                                          ),
                                          const SizedBox(height: 30),
                                          Column(
                                            children: [
                                              for (int j = 0; j < equipmentData['levels'][i]['correct_execution'].length; j++)
                                                ReusableText(
                                                  text: equipmentData['levels'][i]['correct_execution'][j],
                                                  fontWeight: FontWeight.w200,
                                                  size: 12,
                                                  color: AppColors.pBlack87Color,
                                                  decoration: null,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 20,
                                                  align: TextAlign.center,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Column(
                                        children: [
                                          const ReusableText(
                                            text: 'Step by Step Instructions',
                                            fontWeight: FontWeight.w600,
                                            size: 18,
                                            color: AppColors.pBlack87Color,
                                            decoration: null,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            align: TextAlign.center,
                                          ),
                                          const SizedBox(height: 30),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              for (int j = 0; j < equipmentData['levels'][i]['step_by_step_instructions'].length; j++)
                                                ReusableText(
                                                  text: equipmentData['levels'][i]['step_by_step_instructions'][j],
                                                  fontWeight: FontWeight.w200,
                                                  size: 12,
                                                  color: AppColors.pBlack87Color,
                                                  decoration: null,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 20,
                                                  align: TextAlign.center,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Column(
                                        children: [
                                          const ReusableText(
                                            text: 'Common Mistakes',
                                            fontWeight: FontWeight.w600,
                                            size: 18,
                                            color: AppColors.pBlack87Color,
                                            decoration: null,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            align: TextAlign.center,
                                          ),
                                          const SizedBox(height: 30),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              for (int j = 0; j < equipmentData['levels'][i]['common_mistakes'].length; j++)
                                                ReusableText(
                                                  text: equipmentData['levels'][i]['common_mistakes'][j],
                                                  fontWeight: FontWeight.w200,
                                                  size: 12,
                                                  color: AppColors.pBlack87Color,
                                                  decoration: null,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 20,
                                                  align: TextAlign.center,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Column(
                                        children: [
                                          const ReusableText(
                                            text: 'Video Tutorial',
                                            fontWeight: FontWeight.w600,
                                            size: 18,
                                            color: AppColors.pBlack87Color,
                                            decoration: null,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            align: TextAlign.center,
                                          ),
                                          const SizedBox(height: 30),
                                          GestureDetector(
                                            onTap: () async {
                                              await launchUrlString(equipmentData['levels'][i]['video_tutorial']);
                                            },
                                            child: ReusableText(
                                              text: equipmentData['levels'][i]['video_tutorial'],
                                              fontWeight: FontWeight.w800,
                                              size: 18,
                                              color: AppColors.pGreenColor,
                                              decoration: null,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 20,
                                              align: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      // Existing content continues...
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 5.0,
          bottom: 40.0,
        ),
        child: SizedBox(
          height: screenHeight * 0.065,
          width: double.infinity,
          child: ReusableButton(
            text: _getButtonText(),
            onPressed: () {
              if (isRinging) {
                _audioPlayer.stop();
                setState(() {
                  isRinging = false;
                });
                return;
              }

              if (isDone) {
                _audioPlayer.stop();
                setState(() {
                  _timer?.cancel();
                  _remainingSeconds = 0;
                  hasStarted = false;
                  isPaused = false;
                  isRinging = false;
                  isDone = false;
                  currentSet = 1;
                });
                return;
              }

              if (!hasStarted) {
                _startTimer(minutesPerSet);
              } else if (isPaused) {
                _resumeTimer();
              } else {
                _pauseTimer();
              }
            },
            color: AppColors.pGreenColor,
            fontColor: AppColors.pWhiteColor,
            borderRadius: 30.0,
            size: 18,
            weight: FontWeight.w600,
            removePadding: true,
          ),
        ),
      ),
    );
  }
}