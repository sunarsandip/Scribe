import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const CustomTextButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: AppTextStyles.buttonText.copyWith(
            color: AppColors.textButtonColor,
          ),
        ),
      ),
    );
  }
}
