import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AssessmentController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  var selectedMotivationIndex = (-1).obs;
  var selectedGoalIndex = (-1).obs;
  var selectedFocusAreaIndex = (-1).obs;
  var selectedAnyEventsIndex = (-1).obs;
  var selectedIdentifySexIndex = (-1).obs;
  var selectedBodyShape = ''.obs;
  var selectedActivityLevel = ''.obs;
  var selectedFlexibilityLevel = ''.obs;
  var selectedAerobicLevel = ''.obs;
  var selectedFitnessLevel = ''.obs;
  var selectedStopGoalIndex = (-1).obs;
  var selectedWhereYouWorkoutIndex = (-1).obs;
  var selectedAnyDiscomfortIndex = (-1).obs;


  var bmi = RxnDouble(null);
  var bmiCategory = ''.obs;
  var isLoading = false.obs;
  var isButtonEnabled = false.obs;
  var gender = 'Male'.obs;
  var inputMessage = ''.obs;


  var targetWeight = 50.obs;
  var weightChangeHeader = ''.obs;
  var weightChangeSemiHeader = ''.obs;
  var weightChangeMessage = ''.obs;

  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final FocusNode heightFocus = FocusNode();
  final FocusNode weightFocus = FocusNode();
  final FocusNode ageFocus = FocusNode();


  // Methods for updating selections
  void setSelectedMotivationIndex(int index) {
    selectedMotivationIndex.value = index;
  }

  void setSelectedGoalIndex(int index) {
    selectedGoalIndex.value = index;
  }

  void setSelectedFocusAreaIndex(int index) {
    selectedFocusAreaIndex.value = index;
  }

  void setSelectedAnyEventsIndex(int index) {
    selectedAnyEventsIndex.value = index;
  }

  void setSelectedIdentifySexIndex(int index) {
    selectedIdentifySexIndex.value = index;
  }

  void setSelectedStopGoalIndex(int index) {
    selectedStopGoalIndex.value = index;
  }

  void setSelectedWhereYouWorkoutIndex(int index) {
    selectedWhereYouWorkoutIndex.value = index;
  }

  void setSelectedAnyDiscomfortIndex(int index) {
    selectedAnyDiscomfortIndex.value = index;
  }

  final List<String> motivationChoices = [
    "Feel confident",
    "Release stress",
    "Improve health",
    "Boost energy",
    "Get shaped"
  ];

  final List<String> goalChoices = ["Lose weight", "Build muscle", "Keep fit"];

  final List<String> focusAreaChoices = [
    "Arms",
    "Chest",
    "Belly",
    "Glutes",
    "Thigh",
    "Full body",
  ];

  final List<String> eventChoices = [
    "Sport event",
    "Travel",
    "Taking photo",
    "Vacation",
    "THE BIG DAY",
  ];

  final List<String> stopGoalChoices = [
    "Unhealthy eating habits",
    "Lack of motivation",
    "Poor sleep",
    "Lack of guidance",
    "Others",
  ];

  final List<String> whereDoExerciseChoices = [
    "Home",
    "Bed",
    "Yoga mat",
    "Gym",
  ];

  final List<String> discomfortChoices = [
    "None",
    "Back injury",
    "Arm injury",
    "Knee injury",
    "Cardiomyopathy",
  ];


  @override
  void onInit() {
    super.onInit();
    loadAssessmentData();
    heightController.addListener(_onInputFieldChanged);
    weightController.addListener(_onInputFieldChanged);
    ageController.addListener(_onInputFieldChanged);
  }

  Future<void> loadAssessmentData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not logged in.");
      return;
    }

    try {
      final snapshot = await _databaseRef.child("users").child(user.uid).child("assessment").get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        if (data.containsKey('motivation')) {
          String savedMotivation = data['motivation'];
          int index = motivationChoices.indexOf(savedMotivation);
          selectedMotivationIndex.value = index >= 0 ? index : -1;
        } else {
          selectedMotivationIndex.value = -1;
        }

        if (data.containsKey('main_goal')) {
          String savedGoal = data['main_goal'];
          int index = goalChoices.indexOf(savedGoal);
          selectedGoalIndex.value = index >= 0 ? index : -1;
        } else {
          selectedGoalIndex.value = -1;
        }

        if (data.containsKey('focus_area')) {
          String savedFocusArea = data['focus_area'];
          int index = focusAreaChoices.indexOf(savedFocusArea);
          selectedFocusAreaIndex.value = index >= 0 ? index : -1;
        } else {
          selectedFocusAreaIndex.value = -1;
        }

        if (data.containsKey('any_event')) {
          String savedAnyEvent = data['any_event'];
          int index = eventChoices.indexOf(savedAnyEvent);
          selectedAnyEventsIndex.value = index >= 0 ? index : -1;
        } else {
          selectedAnyEventsIndex.value = -1;
        }

        if (data.containsKey('stop_goal')) {
          String savedStopGoal = data['stop_goal'];
          int index = stopGoalChoices.indexOf(savedStopGoal);
          selectedStopGoalIndex.value = index >= 0 ? index : -1;
        } else {
          selectedStopGoalIndex.value = -1;
        }

        if (data.containsKey('where_do_exercise')) {
          String savedWhereDoExercise = data['where_do_exercise'];
          int index = whereDoExerciseChoices.indexOf(savedWhereDoExercise);
          selectedWhereYouWorkoutIndex.value = index >= 0 ? index : -1;
        } else {
          selectedWhereYouWorkoutIndex.value = -1;
        }

        if (data.containsKey('discomfort')) {
          String savedDiscomfort = data['discomfort'];
          int index = discomfortChoices.indexOf(savedDiscomfort);
          selectedAnyDiscomfortIndex.value = index >= 0 ? index : -1;
        } else {
          selectedAnyDiscomfortIndex.value = -1;
        }

        if (data.containsKey('targetWeight') && data['targetWeight'] != null) {
          targetWeight.value = data['targetWeight'];
        }


        if (data.containsKey('body_shape')) {
          selectedBodyShape.value = data['body_shape'] ?? '';
        }

        if (data.containsKey('activity_level')) {
          selectedActivityLevel.value = data['activity_level'] ?? selectedActivityLevel.value;
        }

        if (data.containsKey('flexibility_level')) {
          selectedFlexibilityLevel.value = data['flexibility_level'] ?? selectedFlexibilityLevel.value;
        }

        if (data.containsKey('aerobic_level')) {
          selectedAerobicLevel.value = data['aerobic_level'] ?? selectedAerobicLevel.value;
        }

        if (data.containsKey('fitness_level')) {
          selectedFitnessLevel.value = data['fitness_level'] ?? selectedFitnessLevel.value;
        }

        if (data.containsKey('gender')) {
          gender.value = data['gender'] ?? "Male";
          selectedIdentifySexIndex.value = gender.value == "Male" ? 0 : 1;
        }

        heightController.text = (data['height']?.toString() ?? '0');
        weightController.text = (data['weight']?.toString() ?? '0');
        ageController.text = (data['age']?.toString() ?? '0');

        bmi.value = double.tryParse(data['bmi']?.toString() ?? '');
        bmiCategory.value = data['bmiCategory'] ?? '';

        print("Assessment data loaded successfully.");
      } else {
        print("No assessment data found for user.");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load assessment data: $e",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveAssessmentDataToDatabase() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _databaseRef.child("users").child(user.uid).child("assessment").update({
          "age": int.tryParse(ageController.text) ?? 0,
          "height": double.tryParse(heightController.text) ?? 0.0,
          "weight": double.tryParse(weightController.text) ?? 0.0,
          "bmi": bmi.value,
          "bmiCategory": bmiCategory.value,
          "gender": gender.value,
          "motivation": selectedMotivationIndex.value >= 0
              ? motivationChoices[selectedMotivationIndex.value]
              : null,
          "main_goal": selectedGoalIndex.value >= 0
              ? goalChoices[selectedGoalIndex.value]
              : null,
          "focus_area": selectedFocusAreaIndex.value >= 0
              ? focusAreaChoices[selectedFocusAreaIndex.value]
              : null,
          "any_event": selectedAnyEventsIndex.value >= 0
              ? eventChoices[selectedAnyEventsIndex.value]
              : null,
          "targetWeight": targetWeight.value,
          "body_shape": selectedBodyShape.value,
          "activity_level": selectedActivityLevel.value,
          "flexibility_level": selectedFlexibilityLevel.value,
          "aerobic_level": selectedAerobicLevel.value,
          "fitness_level": selectedFitnessLevel.value,
          "stop_goal": selectedStopGoalIndex.value >= 0
              ? stopGoalChoices[selectedStopGoalIndex.value]
              : null,
          "where_do_exercise": selectedWhereYouWorkoutIndex.value >= 0
              ? whereDoExerciseChoices[selectedWhereYouWorkoutIndex.value]
              : null,
          "discomfort": selectedAnyDiscomfortIndex.value >= 0
              ? discomfortChoices[selectedAnyDiscomfortIndex.value]
              : null,

        });
        print("Assessment data saved successfully.");
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to save assessment data",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> saveAssessmentAnswer(String key, dynamic value) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _databaseRef.child("users").child(user.uid).child("assessment").update({
          key: value,
        });
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to save: $e",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  void setGender(int index) {
    gender.value = index == 0 ? "Male" : "Female";
    selectedIdentifySexIndex.value = index;
    saveAssessmentAnswer("gender", gender.value);
  }

  void setTargetWeight(int weight) {
    targetWeight.value = weight;
    saveAssessmentAnswer("targetWeight", weight);
  }

  Future<void> markDataAsCollected() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _databaseRef.child("users").child(user.uid).update({
          "isDataCollected": true,
        });
        print("isDataCollected updated to true");
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to update isDataCollected: $e",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<String> getFocusAreaFromDatabase() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not logged in.");
      return '';
    }

    try {
      final snapshot = await _databaseRef.child("users").child(user.uid).child("assessment").get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        if (data.containsKey('focus_area')) {
          return data['focus_area'] ?? ''; // Return the focus area string
        } else {
          return ''; // Return empty string if not found
        }
      } else {
        print("No assessment data found for user.");
        return '';
      }
    } catch (e) {
      print("Error fetching focus area: $e");
      return '';
    }
  }


  void validateFields() {
    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);
    int? age = int.tryParse(ageController.text);

    if (height == null || height <= 0) {
      inputMessage.value = "Please input your height";
      resetBMI();
    } else if (weight == null || weight <= 0) {
      inputMessage.value = "Please input your weight";
      resetBMI();
    } else if (age == null || age <= 0) {
      inputMessage.value = "Please input your age";
      resetBMI();
    } else {
      inputMessage.value = "";
      isButtonEnabled.value = true;
      calculateBMI();
    }
  }

  void resetBMI() {
    bmi.value = null;
    bmiCategory.value = "";
    weightChangeHeader.value = "";
    weightChangeSemiHeader.value = "";
    weightChangeMessage.value = "";
  }

  void calculateBMI() async {
    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);
    int? age = int.tryParse(ageController.text);

    if (height == null || weight == null || age == null) {
      resetBMI();
      inputMessage.value = "Please fill out all fields to calculate BMI.";
      isButtonEnabled.value = false;
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    double heightInMeters = height / 100;
    bmi.value = weight / (heightInMeters * heightInMeters);
    bmiCategory.value = getBMIClassification(bmi.value!, age, gender.value);

    inputMessage.value = "";
    isLoading.value = false;

    calculateWeightChangeFeedback();

    saveAssessmentDataToDatabase();
  }

  String getBMIClassification(double bmi, int age, String gender) {
    if (age >= 18) {
      if (gender == "Male") {
        if (bmi < 18.5) return "Underweight";
        if (bmi < 24.9) return "Normal weight";
        if (bmi < 29.9) return "Overweight";
        return "Obese";
      } else {
        if (bmi < 18.0) return "Underweight";
        if (bmi < 24.0) return "Normal weight";
        if (bmi < 29.0) return "Overweight";
        return "Obese";
      }
    } else if (age >= 13 && age < 18) {
      if (bmi < 16.5) return "Underweight";
      if (bmi < 23.0) return "Normal weight";
      if (bmi < 27.0) return "Overweight";
      return "Obese";
    } else {
      if (bmi < 15.0) return "Underweight";
      if (bmi < 22.0) return "Normal weight";
      if (bmi < 26.0) return "Overweight";
      return "Obese";
    }
  }

  Color getBMIResultColor() {
    switch (bmiCategory.value) {
      case "Normal weight":
        return Colors.green;
      case "Overweight":
        return Colors.yellow[600]!;
      case "Obese":
      case "Underweight":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String getBMIMessage() {
    switch (bmiCategory.value) {
      case "Normal weight":
        return "You've got a great figure! Keep it up!";
      case "Overweight":
        return "Let's aim for a healthier weight!";
      case "Obese":
        return "Consider a health plan for better results.";
      case "Underweight":
        return "You're a bit underweight. Take care!";
      default:
        return "Please enter your height, weight, and age to calculate BMI.";
    }
  }

  void _onInputFieldChanged() {
    if (heightController.text.isEmpty || weightController.text.isEmpty || ageController.text.isEmpty) {
      resetBMI();
      inputMessage.value = "Please fill out all fields to calculate BMI.";
      isButtonEnabled.value = false;
    } else {
      validateFields();
    }
  }

  void calculateWeightChangeFeedback() {
    double? currentWeight = double.tryParse(weightController.text);
    if (currentWeight == null) return;

    double heightInMeters = (double.tryParse(heightController.text) ?? 0) / 100;
    double targetBmi = targetWeight.value / (heightInMeters * heightInMeters);
    double weightChangePercent = ((targetWeight.value - currentWeight) / currentWeight * 100).abs();

    // Calculate BMI classification based on the target weight
    String bmiClassification = getBMIClassification(targetBmi, int.tryParse(ageController.text) ?? 18, gender.value);

    // Determine if the goal is to gain, maintain, or lose weight
    String goal = targetWeight.value > currentWeight
        ? "gain"
        : (targetWeight.value < currentWeight ? "lose" : "maintain");
    String gainOrLossText = goal == "gain"
        ? "You will gain ${weightChangePercent.toStringAsFixed(1)}% of body weight"
        : goal == "lose"
        ? "You will lose ${weightChangePercent.toStringAsFixed(1)}% of body weight"
        : "Maintain your current weight for optimal health";

    // Feedback structure based on BMI classification, target BMI range, and goal
    if (bmiClassification == "Underweight") {
      weightChangeHeader.value = goal == "gain" ? "GOOD CHOICE!" : "CAUTION!";
      weightChangeSemiHeader.value = gainOrLossText;

      if (goal == "gain") {
        weightChangeMessage.value = "Gaining weight can lead to:\n"
            "- Increased energy and stamina\n"
            "- Improved mood and resilience";
      } else if (goal == "maintain") {
        weightChangeMessage.value = "Maintaining an underweight range may:\n"
            "- Affect muscle strength\n"
            "- Reduce energy and immunity";
      } else {
        weightChangeMessage.value = "Losing weight at this range could:\n"
            "- Further reduce muscle mass\n"
            "- Negatively impact health";
      }

    } else if (bmiClassification == "Normal weight") {
      weightChangeHeader.value = "GREAT CHOICE!";
      weightChangeSemiHeader.value = gainOrLossText;

      if (goal == "gain") {
        weightChangeMessage.value = "A slight weight gain can:\n"
            "- Build muscle and endurance\n"
            "- Enhance physical strength";
      } else if (goal == "maintain") {
        weightChangeMessage.value = "Maintaining this range supports:\n"
            "- Strong energy levels\n"
            "- Balanced metabolism";
      } else {
        weightChangeMessage.value = "Losing weight in this range might:\n"
            "- Not be necessary for health\n"
            "- Reduce energy and stamina";
      }

    } else if (bmiClassification == "Overweight") {
      weightChangeHeader.value = goal == "lose" ? "GOOD CHOICE!" : "CAUTION!";
      weightChangeSemiHeader.value = gainOrLossText;

      if (goal == "gain") {
        weightChangeMessage.value = "Gaining weight may:\n"
            "- Increase strain on joints\n"
            "- Raise health risks over time";
      } else if (goal == "maintain") {
        weightChangeMessage.value = "Maintaining this range may:\n"
            "- Keep existing health risks\n"
            "- Impact energy and endurance";
      } else {
        weightChangeMessage.value = "Losing weight can improve:\n"
            "- Joint health and mobility\n"
            "- Overall energy and well-being";
      }

    } else { // Obese classification
      weightChangeHeader.value = goal == "lose" ? "HIGH PRIORITY!" : "HIGH RISK!";
      weightChangeSemiHeader.value = gainOrLossText;

      if (goal == "gain") {
        weightChangeMessage.value = "Gaining more weight could:\n"
            "- Significantly raise health risks\n"
            "- Impact quality of life";
      } else if (goal == "maintain") {
        weightChangeMessage.value = "Maintaining this weight could:\n"
            "- Increase risk for chronic conditions\n"
            "- Affect mobility and breathing";
      } else {
        weightChangeMessage.value = "Losing weight may help prevent:\n"
            "- Heart disease and diabetes\n"
            "- Breathing and mobility issues";
      }
    }
  }
}
