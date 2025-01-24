import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/api/services/food_data.dart';
import 'package:pulsestrength/features/meal/controller/meal_controller.dart';
import 'package:pulsestrength/features/meal/screen/add_meal_page.dart';
import 'package:pulsestrength/features/meal/screen/widget/meal_card_widget.dart';
import 'package:pulsestrength/features/meal/screen/widget/meal_history_widget.dart';
import 'package:pulsestrength/utils/global_assets.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

String selected = '';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage>
    with AutomaticKeepAliveClientMixin {
  final MealController controller = Get.put(MealController());
  double autoScale = Get.width / 360;
  bool _showShadow = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.scrollController.hasClients &&
          controller.scrollController.offset > 0) {
        setState(() {
          _showShadow = true;
        });
      }
    });

    controller.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (controller.scrollController.offset > 0 && !_showShadow) {
      setState(() {
        _showShadow = true;
      });
    } else if (controller.scrollController.offset <= 0 && _showShadow) {
      setState(() {
        _showShadow = false;
      });
    }
  }

  @override
  void dispose() {
    controller.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  final TextEditingController textController = TextEditingController();

  bool insearch = false;

  String query = '';
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.pBGWhiteColor,
        elevation: _showShadow ? 6.0 : 0.0,
        shadowColor: Colors.black26,
        surfaceTintColor: AppColors.pNoColor,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0 * autoScale),
          decoration: BoxDecoration(
            color: AppColors.pLightGreyColor,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.pGreyColor),
              const SizedBox(width: 5),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: TextField(
                    controller: textController,
                    onChanged: (value) {
                      setState(() {
                        insearch = true;
                        query = value;
                      });
                    },
                    cursorColor: AppColors.pBlackColor,
                    decoration: const InputDecoration(
                      hintText: 'Search food',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Colors.black54, fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.clearSearch();
                  textController.clear(); // Clears the TextField content
                  setState(() {
                    insearch = false;
                  });
                },
                child: const Icon(Icons.close, color: AppColors.pGreyColor),
              )
            ],
          ),
        ),
      ),
      body: insearch
          ? searchWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MealCardWidget(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(
                        text: "Add food",
                        onPressed: () {
                          // Action for Create meal
                          setState(() {
                            insearch = true;
                          });
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => const AddMealPage()));
                        },
                      ),
                      // const SizedBox(width: 15),
                      // _buildButton(
                      //   text: "Quick add",
                      //   onPressed: () {
                      //     if (selected != '') {
                      //       quickMealDialog();
                      //     }
                      //     // Action for Quick add
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const MealHistoryList()
                ],
              ),
            ),
    );
  }

  searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Meal History" Header
            Padding(
              padding: EdgeInsets.only(left: 5.0 * autoScale),
              child: ReusableText(
                text: "Suggestions",
                size: 24 * autoScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Meal History List
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: foodList.length,
              itemBuilder: (context, index) {
                final meal = foodList[index];
                return meal['name']
                        .toString()
                        .toLowerCase()
                        .toLowerCase()
                        .contains(query.toLowerCase())
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 4 * autoScale),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddMealPage(
                                      data: meal,
                                    )));
                          },
                          child: Container(
                            padding: EdgeInsets.all(10 * autoScale),
                            decoration: BoxDecoration(
                              color: AppColors.pNoColor,
                              borderRadius:
                                  BorderRadius.circular(12 * autoScale),
                            ),
                            child: Row(
                              children: [
                                // Meal Image
                                Container(
                                  width: 60.0 * autoScale,
                                  height: 60.0 * autoScale,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(8 * autoScale),
                                    image: DecorationImage(
                                      image: NetworkImage(meal['img']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12 * autoScale),

                                // Meal Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Meal Title
                                      ReusableText(
                                        text: meal['name'],
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
                                            label: meal['calories'].toString(),
                                            color: AppColors.pDarkOrangeColor,
                                          ),
                                          SizedBox(width: 8 * autoScale),
                                          _buildInfoChip(
                                            iconData: Icons.scale,
                                            label:
                                                meal['servingSize'].toString(),
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
                        ))
                    : const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0 * autoScale),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pOrangeColor,
            padding: EdgeInsets.symmetric(vertical: 12.0 * autoScale),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0 * autoScale),
            ),
            elevation: 3,
          ),
          child: ReusableText(
            text: text,
            fontWeight: FontWeight.bold,
            size: 18.0 * autoScale,
          ),
        ),
      ),
    );
  }

  quickMealDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quick add',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _InputRow(label: 'Fat', controller: fat),
                const SizedBox(height: 12),
                _InputRow(
                  label: 'Protein',
                  controller: protein,
                ),
                const SizedBox(height: 12),
                _InputRow(
                  label: 'Calories',
                  controller: calories,
                ),
                const SizedBox(height: 12),
                _InputRow(
                  label: 'Carbohydrates',
                  controller: carbs,
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, thickness: 1),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await FirebaseFirestore.instance
                              .collection('Foods')
                              .doc(selected)
                              .update({
                            'fats': fat.text == '' ? 0 : int.parse(fat.text),
                            'protein': protein.text == ''
                                ? 0
                                : int.parse(protein.text),
                            'calories': calories.text == ''
                                ? 0
                                : int.parse(calories.text),
                            'carbs':
                                carbs.text == '' ? 0 : int.parse(carbs.text),
                          });
                        },
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

final fat = TextEditingController();
final protein = TextEditingController();
final calories = TextEditingController();
final carbs = TextEditingController();

class _InputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _InputRow({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        Container(
            width: 100,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              keyboardType: TextInputType.number,
            ))
      ],
    );
  }
}