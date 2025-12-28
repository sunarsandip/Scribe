import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';

class MeetingPopupMenu extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  const MeetingPopupMenu({
    super.key,
    required this.onDelete,
    required this.onShare,
    required this.onEdit
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      icon: Icon(Icons.menu, color: AppColors.iconButtonColor),
      itemBuilder: (context) => [
        _popupMenuItem(
          text: "Edit",
          icon: Icons.edit,
          iconColor: AppColors.greenColor,
          onTap: onEdit,
        ),
        _popupMenuItem(
          text: "Delete",
          icon: Icons.delete,
          iconColor: AppColors.redColor,
          onTap: onDelete,
        ),
        _popupMenuItem(
          text: "Share",
          icon: Icons.share,
          iconColor: AppColors.iconButtonColor,
          onTap: onShare,
        ),
      ],
    );
  }

  PopupMenuEntry _popupMenuItem({
    required String text,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        spacing: 8,
        children: [
          Icon(icon, color: iconColor),
          Text(text),
        ],
      ),
    );
  }
}
