import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';

class RecordButton extends StatelessWidget {
  final VoidCallback onTap;
  const RecordButton({super.key, required this.mq, required this.onTap});

  final Size mq;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        splashColor: AppColors.accentColor,
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          height: mq.height * 0.38,
          width: mq.width * 0.38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.iconButtonColor, AppColors.accentColor],
            ),
          ),
          child: Icon(Icons.mic_rounded, color: AppColors.whiteColor, size: 38),
        ),
      ),
    );
  }
}
