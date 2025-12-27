import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/core/user_feedback/user_feedback.dart';
import 'package:scribe/providers/user_provider.dart';
import 'package:scribe/views/screens/profile/widgets/profile_header.dart';
import 'package:scribe/views/screens/profile/widgets/setting_card.dart';
import 'package:scribe/views/screens/profile/widgets/setting_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            onPressed: () {
              UserFeedback.showLogoutDialog(context);
            },
            icon: Icon(FeatherIcons.logOut, color: AppColors.iconButtonColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(),
            const SizedBox(height: 34),

            // Profile Header Section
            Consumer(
              builder: (context, ref, child) {
                final userData = ref.watch(getUserProvider);
                return userData.when(
                  data: (data) {
                    return ProfileHeader(
                      userData: data!,
                      onTap: () {
                        context.pushNamed("updateProfile", extra: data);
                      },
                    );
                  },
                  error: (error, stack) {
                    return Center(child: Text("No user found"));
                  },
                  loading: () {
                    return SizedBox();
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings List
                  SettingCard(
                    children: [
                      SettingItem(
                        icon: FeatherIcons.package,
                        title: 'Request Feature',
                        subtitle: 'Request directly to Scribe\'s Team',
                        onTap: () {
                          context.pushNamed("requestFeature");
                        },
                      ),
                      SettingItem(
                        icon: Icons.bug_report_outlined,
                        title: 'Report a Bug',
                        subtitle: 'Contribute to make the app bug free',
                        onTap: () {},
                      ),
                      SettingItem(
                        icon: FeatherIcons.mic,
                        title: 'Recording Settings',
                        subtitle: 'Audio quality, storage preferences',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SettingCard(
                    children: [
                      SettingItem(
                        icon: FeatherIcons.star,
                        title: 'Rate App',
                        subtitle: 'Rate us on Play & App store',
                        onTap: () {},
                      ),
                      SettingItem(
                        icon: FeatherIcons.info,
                        title: 'About',
                        subtitle: 'App version, terms & conditions',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}