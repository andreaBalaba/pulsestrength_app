import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addDailyPlan() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final ref = FirebaseDatabase.instance.ref('users/$uid/Daily Plan');

  final json = {
    'date': '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
    'workouts': [],
    'calories': 0,
    'steps': 0,
    'water': 0,
    'sleep': 0,
    'week': DateTime.now().weekday,
    'id': ref.key,
  };

  await ref.set(json);

  return json;
}
