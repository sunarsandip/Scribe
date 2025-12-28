import 'package:flutter/material.dart';
import 'package:scribe/controllers/auth_controller.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class UserFeedback {
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: AppTextStyles.title.copyWith(color: AppColors.redColor),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.normalText.copyWith(
              color: AppColors.primaryTextColor,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.normalText.copyWith(
                  color: AppColors.lightTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                AuthController().logOut();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.redColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Logout',
                style: AppTextStyles.buttonText.copyWith(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showCustomDialog({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmText,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: AppTextStyles.title.copyWith(color: AppColors.redColor),
          ),
          content: Text(
            description,
            style: AppTextStyles.normalText.copyWith(
              color: AppColors.primaryTextColor,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: onCancel,
              child: Text(
                'Cancel',
                style: AppTextStyles.normalText.copyWith(
                  color: AppColors.lightTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.redColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                confirmText,
                style: AppTextStyles.buttonText.copyWith(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows an error snackbar at the top of the screen
  static void showErrorSnackbar(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        textAlign: TextAlign.left,
        message: message,
        textStyle: AppTextStyles.normalText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Shows a success snackbar at the top of the screen
  static void showSuccessSnackbar(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        textAlign: TextAlign.left,
        message: message,
        textStyle: AppTextStyles.normalText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Shows an info snackbar at the top of the screen
  static void showInfoSnackbar(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        message: message,
        textAlign: TextAlign.left,
        textStyle: AppTextStyles.normalText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  
}