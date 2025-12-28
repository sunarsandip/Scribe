import 'dart:ui';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';

class CustomButtomNav extends StatelessWidget {
  final bool isRecording;
  final int currentIndex;
  final Function(int) onTap;

  const CustomButtomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(61, 80, 80, 80),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildNavItem(
                    icon: FeatherIcons.home,
                    label: 'Home',
                    index: 0,
                    isSelected: currentIndex == 0,
                  ),
                ),
                SizedBox(width: 90),

                Expanded(
                  child: _buildNavItem(
                    icon: FeatherIcons.user,
                    label: 'Profile',
                    index: 2,
                    isSelected: currentIndex == 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    bool isDisabled = isRecording && index != 1;

    return GestureDetector(
      onTap: () => isDisabled ? null : onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.accentColor, AppColors.whiteColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color.fromARGB(0, 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.normalIconColor
                    : AppColors.whiteColor,
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.navBarText.copyWith(
                  color: isSelected
                      ? AppColors.normalIconColor
                      : AppColors.whiteColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
