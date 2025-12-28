import 'package:flutter/material.dart';

class PrimaryButtonWithIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final VoidCallback onTap;
  final bool? isLoading;
  const PrimaryButtonWithIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onTap,
    this.isLoading
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      onPressed: isLoading??false?null:onTap,
      label: isLoading??false?CircularProgressIndicator():Text(text),
      icon: isLoading??false?null:Icon(icon),
    );
  }
}
