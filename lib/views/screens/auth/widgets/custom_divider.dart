import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(child: Divider()),
        Text(
          "Or Log in With",
          style: TextStyle(color: AppColors.lightTextColor),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
