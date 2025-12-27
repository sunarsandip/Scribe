import 'dart:io';

import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scribe/controllers/auth_controller.dart';
import 'package:scribe/controllers/user_controller.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/core/user_feedback/user_feedback.dart';
import 'package:scribe/models/user_model.dart';
import 'package:scribe/providers/user_provider.dart';
import 'package:scribe/views/screens/profile/widgets/password_field.dart';
import 'package:scribe/views/widgets/primary_button.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  final UserModel userData;
  const UpdateProfileScreen({super.key, required this.userData});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  XFile? pickedImage;
  bool isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    userNameController.text = widget.userData.userName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text("Update Profile", style: AppTextStyles.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(),
              const SizedBox(height: 32),

              // Form Section
              _buildFormSection(),
              const SizedBox(height: 32),

              // Password Section
              _isPasswordAuthUser ? _buildPasswordSection() : SizedBox(),
              const SizedBox(height: 20),

              // Update Button
              PrimaryButton(
                isLoading: isLoading,
                text: "Update Changes",
                backgroundColor: AppColors.blackColor,
                textColor: AppColors.whiteColor,
                onTap: () => isLoading ? null : _updateProfile(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.8, color: AppColors.lightBlackColor),
      ),
      child: Column(
        children: [
          Text(
            "Profile Picture",
            style: AppTextStyles.title.copyWith(
              fontSize: 18,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Material(
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.darkBackgroundColor,
                  backgroundImage: pickedImage == null
                      ? NetworkImage(widget.userData.profilePic)
                      : FileImage(File(pickedImage!.path)) as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  elevation: 2,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () async {
                      final selectedImage = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (selectedImage != null) {
                        setState(() {
                          pickedImage = selectedImage;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FeatherIcons.camera,
                        size: 20,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Tap the camera icon to change your profile picture",
            style: AppTextStyles.normalText.copyWith(
              fontSize: 13,
              color: AppColors.lightTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.8, color: AppColors.lightBlackColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: AppTextStyles.title.copyWith(
              fontSize: 18,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Full Name",
                style: AppTextStyles.normalText.copyWith(
                  fontSize: 14,
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: userNameController,
                style: AppTextStyles.normalText.copyWith(
                  fontSize: 16,
                  color: AppColors.primaryTextColor,
                ),
                decoration: InputDecoration(
                  hintText: "Enter your full name",
                  hintStyle: AppTextStyles.normalText.copyWith(
                    color: AppColors.lightTextColor,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.lightBlackColor,
                      width: 0.8,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.lightBlackColor,
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Email field (read-only for display)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Email Address",
                style: AppTextStyles.normalText.copyWith(
                  fontSize: 14,
                  color: AppColors.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBackgroundColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lightBlackColor,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  widget.userData.email,
                  style: AppTextStyles.normalText.copyWith(
                    fontSize: 16,
                    color: AppColors.lightTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Email cannot be changed",
                style: AppTextStyles.normalText.copyWith(
                  fontSize: 12,
                  color: AppColors.lightTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.8, color: AppColors.lightBlackColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Change Password",
            style: AppTextStyles.title.copyWith(
              fontSize: 18,
              color: AppColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Leave blank if you don't want to change your password",
            style: AppTextStyles.normalText.copyWith(
              fontSize: 12,
              color: AppColors.lightTextColor,
            ),
          ),
          const SizedBox(height: 20),

          // Current password
          PasswordField(
            label: "Current Password",
            controller: currentPasswordController,
            hintText: "Enter your current password",
            obscureText: _obscureCurrentPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureCurrentPassword = !_obscureCurrentPassword;
              });
            },
          ),

          const SizedBox(height: 16),

          // New Password
          PasswordField(
            label: "New Password",
            controller: newPasswordController,
            hintText: "Enter your new password",
            obscureText: _obscureNewPassword,
            onToggleVisibility: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
          SizedBox(height: 16),

          // change password button
          PrimaryButton(
            height: 50,
            text: "Change Password",
            backgroundColor: AppColors.redColor,
            textColor: AppColors.whiteColor,
            onTap: () async {
              final res = await AuthController().changePassword(
                newPasswordController.text,
                currentPasswordController.text,
                widget.userData.email,
                context,
              );
              if (res["success"]) {
                UserFeedback.showSuccessSnackbar(context, res["message"]);
              } else {
                UserFeedback.showErrorSnackbar(context, res["message"]);
              }
              currentPasswordController.clear();
              newPasswordController.clear();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      String? newProfilePicUrl;
      if (pickedImage != null) {
        newProfilePicUrl = await UserController().uploadProfilePic(
          widget.userData.profilePic,
          pickedImage!,
        );
        if (newProfilePicUrl == null) {
          UserFeedback.showErrorSnackbar(
            context,
            "Failed to update profile pic",
          );
          return;
        }
      }

      UserModel updatedUser = widget.userData.copyWith(
        userName: userNameController.text,
        profilePic: newProfilePicUrl ?? widget.userData.profilePic,
      );
      final success = await UserController().updateUserProfile(
        updatedUser,
        widget.userData.uid,
      );
      if (success) {
        UserFeedback.showSuccessSnackbar(
          context,
          "Profile updated successfully",
        );
        ref.invalidate(getUserProvider);
        context.pop();
      } else {
        UserFeedback.showErrorSnackbar(context, "Failed to update profile!");
      }
    } catch (e) {
      UserFeedback.showErrorSnackbar(
        context,
        "An error occured while updating profile",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  bool get _isPasswordAuthUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Check if user has password provider
    for (UserInfo userInfo in user.providerData) {
      if (userInfo.providerId == 'password') {
        return true;
      }
    }
    return false;
  }
}