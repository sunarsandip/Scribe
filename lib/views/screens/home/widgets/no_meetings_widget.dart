import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class NoMeetingsWidget extends StatelessWidget {
  const NoMeetingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(width: double.infinity),

          // Animated container with icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  Icons.file_present_outlined,
                  size: 64,
                  color: AppColors.normalIconColor,
                ),
              );
            },
          ),
          SizedBox(height: 12),

          // Main title
          Text(
            "No Notes Yet",
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            "Your recorded notes will appear here",
            style: AppTextStyles.normalText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
