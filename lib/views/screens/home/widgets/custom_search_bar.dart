import 'package:flutter/material.dart';
import 'package:scribe/core/styles/app_colors.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 48, end: 48).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: AnimatedBuilder(
          animation: _heightAnimation,
          builder: (context, child) {
            return SizedBox(
              height: _heightAnimation.value,
              child: TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search meetings...',
                  filled: true,
                  fillColor: AppColors.lightBlackColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
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
                  prefixIcon: Icon(
                    Icons.search,
                    color: _isFocused
                        ? AppColors.iconButtonColor
                        : AppColors.normalIconColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
