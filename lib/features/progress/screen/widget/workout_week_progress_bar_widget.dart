import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class WorkoutChartWidget extends StatelessWidget {
  const WorkoutChartWidget({super.key});


  @override
  Widget build(BuildContext context) {
    double autoScale = Get.width / 360;

    List<int> dailyWorkoutMinutes = [90, 45, 120, 75, 60, 150, 30];

    String formatTime(int minutes) {
      int hours = minutes ~/ 60; 
      int mins = minutes % 60;
      return '$hours hr ${mins > 0 ? '$mins min' : ''}';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0 * autoScale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(
                    text: "Workout",
                    fontWeight: FontWeight.bold,
                    size: 24 * autoScale,
                  ),
                  ReusableText(
                    text: "Weekly Average",
                    size: 14 * autoScale,
                    color: AppColors.pBGGreyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18 * autoScale,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(text: "1 ", style: TextStyle(color: AppColors.pBlackColor)),
                          TextSpan(text: 1 == 1 ? "hr " : "hrs ", style: TextStyle(fontSize: 14 * autoScale, color: AppColors.pBGGreyColor)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18 * autoScale,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(text: "1 ", style: TextStyle(color: AppColors.pBlackColor)),
                          TextSpan(text: 1 == 1 ? "hr " : "hrs ", style: TextStyle(fontSize: 14 * autoScale, color: AppColors.pBGGreyColor)),
                          const TextSpan(text: 25 > 0 ? "25 " : "", style: TextStyle(color: AppColors.pBlackColor)),
                          TextSpan(text: (25 == 1) ? "min" : "mins", style: TextStyle(fontSize: 14 * autoScale, color: AppColors.pBGGreyColor)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (dailyWorkoutMinutes.reduce((a, b) => a > b ? a : b) * 1.2).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      int minutes = rod.toY.toInt();
                      return BarTooltipItem(
                        formatTime(minutes),
                        const TextStyle(color: AppColors.pWhiteColor, fontFamily: 'Poppins'),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const days = ["S", "M", "T", "W", "T", "F", "S"];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ReusableText(
                            text: days[value.toInt()],
                            size: 14 * autoScale,
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: dailyWorkoutMinutes.asMap().entries.map((entry) {
                  int index = entry.key;
                  int value = entry.value;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value.toDouble(),
                        color: AppColors.pOrangeColor,
                        width: 16 * autoScale,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (dailyWorkoutMinutes.reduce((a, b) => a > b ? a : b) * 1.2).toDouble(),
                          color: AppColors.pLightGreyColor,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
