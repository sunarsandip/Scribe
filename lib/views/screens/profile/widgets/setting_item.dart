import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class SettingItem extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool? showArrow;
  const SettingItem({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showArrow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.normalIconColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.normalText.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.normalText.copyWith(
                        fontSize: 13,
                        color: AppColors.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow ?? true)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.lightTextColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
