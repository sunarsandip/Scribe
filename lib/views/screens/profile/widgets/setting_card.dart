import 'package:flutter/widgets.dart';
import 'package:scribe/core/styles/app_colors.dart';

class SettingCard extends StatelessWidget {
  final List<Widget> children;
  const SettingCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 0.8, color: AppColors.lightBlackColor),
      ),
      child: Column(children: children),
    );
  }
}
