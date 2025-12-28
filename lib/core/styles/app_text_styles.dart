import 'package:flutter/widgets.dart';
import 'package:scribe/core/styles/app_colors.dart';

class AppTextStyles {
  static final TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle h2 = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTextColor,
  );
  static final TextStyle navBarText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.whiteColor,
  );
  static final TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.whiteColor,
  );
  static final TextStyle normalText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextColor,
  );

  static final TextStyle smallText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextColor,
  );
  
}