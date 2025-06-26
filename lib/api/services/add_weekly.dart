import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addWeekly() async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref('users/$uid/Weekly');

    final json = {
      '1': {
        'workouts': 0,
        'steps': 0,
        'water': 0,
        'sleep': 0,
        'calories': 0,
        'mins': 0,
      },
      '2': {
        'workouts': 0,
        'steps': 0,
        'water': 0,
        'sleep': 0,
        'calories': 0,
        'mins': 0,
      },
      '3': {
        'workouts': 0,
        'steps': 0,
        'water': 0,
        'sleep': 0,
        'calories': 0,
        'mins': 0,
      },
      '4': {
        'workouts': 0,
        'steps': 0,
        'water': 0,
        'sleep': 0,
        'calories': 0,
        'mins': 0,
      },
      '5': {
        'workouts': 0,
        'steps': 0,
        'water': 0,
        'sleep': 0,
        'calories': 0,
        'mins': 0,
      },
      '6': {
        'workouts': 0,
        'steps': 0,
        'water': 0,
        'sleep': 0,
        'calories': 0,
        'mins': 0,
      },
      '7': {
        'workouts': 0,
        'steps': 0,
        'water': 0,
        'sleep': 0,
        'calories': 0,
        'mins': 0,
      },
      'dateTime': DateTime.now().toIso8601String(),
      'year': DateTime.now().year.toString(),
      'month': DateTime.now().month.toString(),
      'day': DateTime.now().day.toString(),
    };

    await ref.set(json);
    print('Weekly data added successfully');
  } catch (e) {
    print('Error adding weekly data: $e');
  }
}
