import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';

class CustomTabBar extends StatefulWidget {
  final Function(int)? onTabChanged;
  final TabController? externalController;
  const CustomTabBar({super.key, this.onTabChanged, this.externalController});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Summary', 'To-Do', 'Transcript'];

  @override
  void initState() {
    super.initState();
    _tabController =
        widget.externalController ??
        TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (widget.onTabChanged != null) {
      widget.onTabChanged!(_tabController.index);
    }
  }

  @override
  void dispose() {
    if (widget.externalController == null) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            indicator: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightBlackColor,
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(6),
            labelColor: Colors.black,
            dividerColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          // Horizontal dividers
          Positioned.fill(
            child: Row(
              children: [
                Expanded(child: Container()),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: AppColors.lightBlackColor,
                ),
                Expanded(child: Container()),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: AppColors.lightBlackColor,
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
