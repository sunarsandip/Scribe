import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/views/screens/features/features_screen.dart';
import 'package:scribe/views/screens/home/home_screen.dart';
import 'package:scribe/views/screens/main/widgets/custom_bottom_nav.dart';
import 'package:scribe/views/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [HomeScreen(), FeaturesScreen(), ProfileScreen()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex != 1
          ? Container(
              margin: EdgeInsets.only(bottom: 50),
              child: InkWell(
                splashColor: AppColors.accentColor,
                onTap: () {
                  context.pushNamed('features');
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.iconButtonColor,
                        AppColors.accentColor,
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.backgroundColor,
                      width: 4,
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Image.asset(
                    "assets/images/ai_star.png",
                    height: 28,
                    width: 28,
                  ),
                ),
              ),
            )
          : null,
      extendBody: true,
      body: Stack(
        children: [
          screens[_currentIndex],
          if (_currentIndex != 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomButtomNav(
                isRecording: false,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}