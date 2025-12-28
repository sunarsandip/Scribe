import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class MeetingProcessingIndicator extends StatelessWidget {
  const MeetingProcessingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accentColor, AppColors.whiteColor],
        ),
        border: Border.all(width: 1, color: AppColors.lightBlackColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("New meeting is being processed.", style: AppTextStyles.h3),
          SizedBox(height: 8),

          Text(
            "AI is processing your meeting...",
            style: AppTextStyles.normalText,
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor: AppColors.blackColor,
            color: AppColors.whiteColor,
          ),
        ],
      ),
    );
  }
}
