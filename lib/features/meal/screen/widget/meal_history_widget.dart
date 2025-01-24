import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:pulsestrength/features/meal/controller/meal_controller.dart';
import 'package:pulsestrength/features/meal/screen/add_meal_page.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class MealHistoryList extends StatefulWidget {
  const MealHistoryList({super.key});

  @override
  State<MealHistoryList> createState() => _MealHistoryListState();
}

class _MealHistoryListState extends State<MealHistoryList> {
  final databaseRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 360;
    //final MealController controller = Get.put(MealController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Meal History" Header
        Padding(
          padding: EdgeInsets.only(left: 5.0 * autoScale),
          child: ReusableText(
            text: "History",
            size: 24 * autoScale,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Meal History List
        StreamBuilder(
          stream: databaseRef
            .child('users')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child('Foods')
            .orderByChild('timestamp')
            .onValue,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return const Center(child: Text('No meals found'));
            }

            // Convert the data to a list
            Map<dynamic, dynamic> foodsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Map<dynamic, dynamic>> foodsList = [];

            foodsMap.forEach((key, value) {
              Map<dynamic, dynamic> food = value as Map<dynamic, dynamic>;
              food['key'] = key; // Save the key for future reference
              foodsList.add(food);
            });

            // Sort the foodsList based on the 'timestamp' field in descending order
            foodsList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: foodsList.length,
              itemBuilder: (context, index) {
                final meal = foodsList[index]['data'];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4 * autoScale),
                  child: MealHistoryCard(
                    meal: meal,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class MealHistoryCard extends StatefulWidget {
  final dynamic meal;

  const MealHistoryCard({
    super.key,
    required this.meal,
  });

  @override
  State<MealHistoryCard> createState() => _MealHistoryCardState();
}

class _MealHistoryCardState extends State<MealHistoryCard> {
  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 360;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddMealPage(
                  inhistory: true,
                  data: widget.meal,
                )));
      },
      child: Container(
        padding: EdgeInsets.all(10 * autoScale),
        decoration: BoxDecoration(
          color: AppColors.pNoColor,
          borderRadius: BorderRadius.circular(12 * autoScale),
        ),
        child: Row(
          children: [
            // Meal Image
            Container(
              width: 60.0 * autoScale,
              height: 60.0 * autoScale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8 * autoScale),
                image: DecorationImage(
                  image: NetworkImage(widget.meal['img']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12 * autoScale),

            // Meal Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Title
                  ReusableText(
                    text: widget.meal['name'],
                    fontWeight: FontWeight.w600,
                    size: 18 * autoScale,
                    color: AppColors.pBlack87Color,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  // Meal Info Chips
                  Row(
                    children: [
                      _buildInfoChip(
                        iconPath: IconAssets.pFireIcon,
                        label: '${widget.meal['calories'].toString()} kcal',
                        color: AppColors.pDarkOrangeColor,
                      ),
                      SizedBox(width: 8 * autoScale),
                      _buildInfoChip(
                        iconData: Icons.scale,
                        label: widget.meal['servingSize'].toString(),
                        color: AppColors.pGreyColor,
                      ),
                      SizedBox(width: 8 * autoScale),
                      // Display date and time
                      ReusableText(
                        text: '${widget.meal['date']} ${widget.meal['time']}',
                        size: 11.0 * autoScale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.pGreyColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Method for Info Chips
  Widget _buildInfoChip({
    String? iconPath,
    IconData? iconData,
    required String label,
    required Color color,
  }) {
    double autoScale = Get.width / 360;

    return Container(
      padding: EdgeInsets.all(3.0 * autoScale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * autoScale),
      ),
      child: Row(
        children: [
          if (iconPath != null)
            Image.asset(
              iconPath,
              height: 12.0 * autoScale,
              width: 12.0 * autoScale,
              color: color,
            )
          else if (iconData != null)
            Icon(
              iconData,
              size: 12.0 * autoScale,
              color: color,
            ),
          SizedBox(width: 4.0 * autoScale),
          ReusableText(
            text: label,
            size: 11.0 * autoScale,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ],
      ),
    );
  }
}