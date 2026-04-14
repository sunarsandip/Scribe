import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel userData;
  final VoidCallback onTap;
  const ProfileHeader({super.key, required this.userData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.backgroundColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(width: 0.8, color: AppColors.lightBlackColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.darkBackgroundColor,
                  backgroundImage: NetworkImage(userData.profilePic),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Name
                      Text(
                        userData.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),

                      // User Email
                      Text(
                        userData.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.normalText.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FeatherIcons.chevronRight,
                  color: AppColors.normalIconColor,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
