import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scribe/controllers/auth_controller.dart';
import 'package:scribe/controllers/user_controller.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/core/user_feedback/user_feedback.dart';
import 'package:scribe/models/user_model.dart';
import 'package:scribe/views/screens/auth/widgets/auth_text_field.dart';
import 'package:scribe/views/screens/auth/widgets/custom_divider.dart';
import 'package:scribe/views/screens/auth/widgets/custom_text_button.dart';
import 'package:scribe/views/screens/auth/widgets/google_login_button.dart';
import 'package:scribe/views/widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool passwordObscured = true;
  bool confirmPasswordObscured = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  bool isGoogleLoading = false;
  bool isLoginLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accentColor, AppColors.backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
          child: LayoutBuilder(
            builder: (context, constrains) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constrains.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sign Up",
                            style: AppTextStyles.h1.copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(height: 40),
                          AuthTextField(
                            title: 'Full name',
                            hintText: 'Enter full name',
                            controller: fullnameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter full name !";
                              }

                              return null;
                            },
                          ),
                          SizedBox(height: 14),
                          AuthTextField(
                            title: 'Email',
                            hintText: 'Enter your email',
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter email !";
                              }
                              // Add email validation
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14),
                          AuthTextField(
                            suffixIcon: passwordObscured
                                ? FeatherIcons.eye
                                : FeatherIcons.eyeOff,
                            isObscure: passwordObscured,
                            onShowPassword: () {
                              setState(() {
                                passwordObscured = !passwordObscured;
                              });
                            },
                            isPassword: true,
                            title: 'Password',
                            hintText: 'Enter your password',
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter Password";
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 60),

                          PrimaryButton(
                            isLoading: isLoginLoading,
                            text: "Sign Up",
                            backgroundColor: AppColors.blackColor,
                            textColor: AppColors.whiteColor,
                            onTap: () async {
                              if (!formKey.currentState!.validate()) return;
                              setState(() {
                                isLoginLoading = true;
                              });
                              final result = await AuthController()
                                  .signupWithEmailPassword(
                                    emailController.text.trim(),
                                    passwordController.text,
                                  );
                              final userId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              final UserModel newUser = UserModel(
                                uid: userId,
                                email: emailController.text,
                                userName: fullnameController.text,
                                profilePic:
                                    "https://i.pinimg.com/736x/87/14/55/8714556a52021ba3a55c8e7a3547d28c.jpg",
                              );
                              await UserController().createUser(
                                newUser,
                                userId,
                              );
                              setState(() {
                                isLoginLoading = false;
                              });
                              if (!mounted) return;

                              if (result['success']) {
                                context.goNamed('mainScreen');
                              } else {
                                UserFeedback.showErrorSnackbar(
                                  context,
                                  result['message'],
                                );
                              }
                            },
                          ),
                          SizedBox(height: 20),

                          CustomDivider(),
                          SizedBox(height: 20),

                          GoogleLoginButton(
                            text: "Sign up With Google",
                            isLoading: isGoogleLoading,
                            onTap: () async {
                              setState(() {
                                isGoogleLoading = true;
                              });
                              final result = await AuthController()
                                  .logInWithGoogle();

                              if (!mounted) return; // Check BEFORE setState

                              setState(() {
                                isGoogleLoading = false;
                              });

                              if (result['success']) {
                                if (!mounted) return; // Check BEFORE navigation
                                context.goNamed("mainScreen");
                              } else {
                                if (!mounted)
                                  return; // Check BEFORE showing snackbar
                                UserFeedback.showErrorSnackbar(
                                  context,
                                  result['message'] ?? "Signup Failed !",
                                );
                              }
                            },
                          ),
                          Spacer(),
                          Center(
                            child: CustomTextButton(
                              text: "Already Have an account? Log In",
                              onTap: () {
                                context.goNamed("login");
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}