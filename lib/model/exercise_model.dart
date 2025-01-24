//temporary model

// Updated WorkoutPlan Model
class WorkoutPlan {
  final String imagePath;
  final String title;
  final String subtitle;
  final String duration;
  final String calories;
  bool isTapped;

  WorkoutPlan({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.calories,
    this.isTapped = false,
  });
}

// Updated DailyTask Model
class DailyTask {
  final String imagePath;
  final String title;
  final String duration;
  final String calories;
  bool isTapped;
  bool isCompleted;

  DailyTask({
    required this.imagePath,
    required this.title,
    required this.duration,
    required this.calories,
    this.isTapped = false,
    this.isCompleted = false, // Default to false
  });
}

// Updated Equipment Model
class Equipment {
  final String name;
  final String image;
  final List<dynamic> levels;
  bool isTapped;

  Equipment({
    required this.name,
    required this.image,
    required this.levels,
    this.isTapped = false,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json['name'],
      image: json['image'],
      levels: json['levels'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      // Add other properties you want to save
    };
  }
}

// Sample Data Model for Meal
class MealHistory {
  final String title;
  final String imagePath;
  final String calories;
  final String weight;
  late final bool isAdded;

  MealHistory({
    required this.title,
    required this.imagePath,
    required this.calories,
    required this.weight,
    this.isAdded = false,
  });
}
