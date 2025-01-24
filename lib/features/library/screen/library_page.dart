import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pulsestrength/features/library/controller/library_controller.dart';
import 'package:pulsestrength/features/library/screen/equipment_page.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with AutomaticKeepAliveClientMixin {
  final LibraryController controller = Get.put(LibraryController());
  final TextEditingController searchController = TextEditingController();
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
    controller.loadSavedEquipment(); // Load saved equipment on initialization
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
    searchController.dispose();
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ReusableText(
              text: 'Equipment Library',
              fontWeight: FontWeight.bold,
              size: 20 * autoScale,
            ),
            const SizedBox(height: 8),
            Container(
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
                    child: TextField(
                      controller: searchController,
                      onChanged: controller.updateSearchQuery,
                      cursorColor: AppColors.pBlackColor,
                      decoration: const InputDecoration(
                        hintText: 'Search equipment',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54, fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  Obx(() => controller.searchQuery.value.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            searchController.clear();
                            controller.updateSearchQuery('');
                          },
                          child: const Icon(Icons.close, color: AppColors.pGreyColor),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pBGWhiteColor,
        elevation: _showShadow ? 6.0 : 0.0,
        shadowColor: Colors.black26,
        centerTitle: true,
        toolbarHeight: 120.0 * autoScale,
        surfaceTintColor: AppColors.pNoColor,
      ),
      body: Obx(() {
        final listToShow = controller.searchQuery.value.isNotEmpty
            ? controller.filteredEquipmentList
            : controller.savedEquipmentList;

        if (listToShow.isEmpty) {
          return Center(
            child: ReusableText(
              text: controller.searchQuery.value.isEmpty
                  ? 'No saved equipment'
                  : 'No results found',
              size: 18 * autoScale,
              color: AppColors.pGreyColor,
            ),
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: 20.0 * autoScale,
            vertical: 8.0 * autoScale,
          ),
          itemCount: listToShow.length,
          itemBuilder: (context, index) {
            final equipment = listToShow[index];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0 * autoScale),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => EquipmentPage(data: equipment.name));
                },
                child: Container(
                  height: 120 * autoScale,
                  decoration: BoxDecoration(
                    color: AppColors.pOrangeColor,
                    borderRadius: BorderRadius.circular(12.0 * autoScale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3 * autoScale,
                        offset: Offset(0, 3 * autoScale),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 5 * autoScale),
                      Padding(
                        padding: EdgeInsets.all(8.0 * autoScale),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0 * autoScale),
                          child: Image.network(
                            equipment.image,
                            width: 80 * autoScale,
                            height: 80 * autoScale,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 5 * autoScale),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0 * autoScale, top: 16 * autoScale, bottom: 16 * autoScale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ReusableText(
                                text: equipment.name,
                                fontWeight: FontWeight.bold,
                                size: 18.0 * autoScale,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4 * autoScale),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ReusableText(
                                    text: 'See details',
                                    color: AppColors.pBlack87Color,
                                    size: 12.0 * autoScale,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      controller.saveEquipment(equipment);
                                    },
                                    child: Obx(
                                      () => Icon(
                                        controller.savedEquipmentList.any((e) => e.name == equipment.name)
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: AppColors.pBlackColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
