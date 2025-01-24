import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

Future addFood(dynamic json1) async {
  final databaseRef = FirebaseDatabase.instance.ref();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final foodsRef = databaseRef.child('users').child(userId).child('Foods').push();

  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  String formattedTime = DateFormat('HH:mm').format(now);

  final json = {
    'data': json1,
    'date': formattedDate,
    'time': formattedTime,
    'timestamp': now.millisecondsSinceEpoch,
  };

  await foodsRef.set(json);
}
