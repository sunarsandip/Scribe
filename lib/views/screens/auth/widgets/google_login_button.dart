import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class GoogleLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool? isLoading;
  const GoogleLoginButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(60),
      onTap: isLoading ?? false ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(width: 1, color: AppColors.blackColor),
        ),
        child: isLoading ?? false
            ? Center(
                child: SizedBox(
                  height: 29,
                  width: 29,
                  child: CircularProgressIndicator(),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/1024px-Google_Favicon_2025.svg.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    text,
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(width: 20, height: 20),
                ],
              ),
      ),
    );
  }
}
