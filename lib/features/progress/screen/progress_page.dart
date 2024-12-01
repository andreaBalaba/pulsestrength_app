import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/home/screen/widget/daily_task_widget.dart';
import 'package:pulsestrength/features/progress/controller/progress_controller.dart';
import 'package:pulsestrength/features/progress/screen/widget/progress_card_widget.dart';
import 'package:pulsestrength/features/progress/screen/widget/workout_week_progress_bar_widget.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with AutomaticKeepAliveClientMixin {
  final ProgressController controller = Get.put(ProgressController());
  bool _showShadow = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.scrollController.hasClients && controller.scrollController.offset > 0) {
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


  @override
  Widget build(BuildContext context) {
    super.build(context);
    double autoScale = Get.width / 360;

    return Scaffold(
      backgroundColor: AppColors.pBGWhiteColor,
      appBar: AppBar(
        title: ReusableText(
          text: 'Today Progress',
          fontWeight: FontWeight.bold,
          size: 20 * autoScale,
        ),
        backgroundColor: AppColors.pBGWhiteColor,
        elevation: _showShadow ? 6.0 : 0.0,
        shadowColor: Colors.black26,
        surfaceTintColor: AppColors.pNoColor,
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        //controller: controller.scrollController,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressCardsWidget(),
            SizedBox(height: 20),
            WorkoutChartWidget(),
            SizedBox(height: 20),
            DailyTaskList(),
          ],
        ),
      ),
    );
  }
}