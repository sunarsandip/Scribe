import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';

/// A configurable recording button. Parent controls the state and callback.
class RecordingActionsButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback? onPressed;
  final bool isPaused;
  final VoidCallback? onDismiss;
  final VoidCallback? onSave;

  const RecordingActionsButton({
    super.key,
    required this.isRecording,
    required this.onPressed,
    required this.isPaused,
    this.onDismiss,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final label = !isPaused ? 'Pause Recording' : 'Resume Recording';
    return Row(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isPaused
            ? iconButton(
                icon: Icons.close_outlined,
                backgroundColor: AppColors.redColor,
                onTap: onDismiss ?? () {},
              )
            : SizedBox(),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            foregroundColor: AppColors.whiteColor,
            backgroundColor: AppColors.iconButtonColor,
          ),
          icon: isRecording
              ? Icon(Icons.pause_rounded)
              : Icon(Icons.play_arrow_rounded),
          onPressed: onPressed,
          label: Text(label),
        ),
        isPaused
            ? iconButton(
                icon: Icons.check_rounded,
                backgroundColor: AppColors.iconButtonColor,
                onTap: onSave ?? () {},
              )
            : SizedBox(),
      ],
    );
  }

  Widget iconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        padding: EdgeInsets.all(16),
        child: Icon(icon, color: AppColors.whiteColor),
      ),
    );
  }
}
