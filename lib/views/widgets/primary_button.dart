import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool? isLoading;
  final double? height;
  final TextStyle? textStyle;
  const PrimaryButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.isLoading,
    this.height,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 60,
      child: ElevatedButton(
        onPressed: isLoading ?? false ? null : onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: textColor,
          backgroundColor: backgroundColor,
          textStyle: AppTextStyles.buttonText,
        ),
        child: isLoading ?? false
            ? CircularProgressIndicator()
            : Text(text, style: textStyle?.copyWith(color: textColor)),
      ),
    );
  }
}
