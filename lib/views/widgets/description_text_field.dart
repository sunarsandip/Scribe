import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class DescriptionTextField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final bool? isObscure;
  final VoidCallback? onShowPassword;
  final bool? isPassword;
  final IconData? suffixIcon;
  final String? Function(String?) validator;
  final int? maxLine;
  final double? height;

  const DescriptionTextField({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.isObscure,
    this.onShowPassword,
    this.isPassword,
    this.suffixIcon,
    required this.validator,
    this.maxLine,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(title, style: AppTextStyles.title),
        Container(
          constraints: height != null
              ? BoxConstraints(minHeight: height!)
              : null,
          child: TextFormField(
            validator: validator,
            obscureText: isObscure ?? false,
            controller: controller,
            maxLines: maxLine,
            minLines: maxLine == null ? 3 : 1,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
              suffixIcon: isPassword ?? false
                  ? IconButton(
                      onPressed: onShowPassword,
                      icon: Icon(suffixIcon),
                    )
                  : null,
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
