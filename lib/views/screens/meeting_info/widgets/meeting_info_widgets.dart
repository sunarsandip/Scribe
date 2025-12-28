import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class MeetingInfoWidgets extends StatelessWidget {
  final IconData icon;
  final String text;
  const MeetingInfoWidgets({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, color: AppColors.normalIconColor),
        Text(text, style: AppTextStyles.normalText),
      ],
    );
  }
}
