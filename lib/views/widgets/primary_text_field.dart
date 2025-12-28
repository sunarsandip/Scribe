import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';

class PrimaryTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  const PrimaryTextField({
    super.key,
    required this.hintText,
    required this.controller, required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(width: 1,color: AppColors.lightBlackColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: AppColors.iconButtonColor,
              width: 2.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          prefixIcon: Icon(prefixIcon, color: AppColors.normalIconColor),
        ),
      ),
    );
  }
}
