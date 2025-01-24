import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addFoodData() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final ref = FirebaseDatabase.instance.ref('users/$uid/foodData');
  
  final json = {
    'basegoal': 0,
    'calories': 0, 
    'carbs': 0,
    'fats': 0,
    'protein': 0,
    'sugar': 0,
    'sodium': 0,
    'fiber': 0,
    'cholesterol': 0,
  };

  await ref.set(json);
}
