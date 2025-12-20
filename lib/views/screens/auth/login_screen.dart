import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scribe/controllers/auth_controller.dart';
import 'package:scribe/core/styles/app_colors.dart';
import 'package:scribe/core/styles/app_text_styles.dart';
import 'package:scribe/core/user_feedback/user_feedback.dart';
import 'package:scribe/views/screens/auth/widgets/auth_text_field.dart';
import 'package:scribe/views/screens/auth/widgets/custom_divider.dart';
import 'package:scribe/views/screens/auth/widgets/custom_text_button.dart';
import 'package:scribe/views/screens/auth/widgets/google_login_button.dart';
import 'package:scribe/views/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoginLoading = false;
  bool isGoogleLoginLoading = false;
  bool isObscured = true;
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
          padding: EdgeInsets.symmetric(horizontal: 12),
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
                            "Log in",
                            style: AppTextStyles.h1.copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(height: 40),
                          AuthTextField(
                            title: 'Email',
                            hintText: 'Enter your email',
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter Email !";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14),
                          AuthTextField(
                            suffixIcon: isObscured
                                ? FeatherIcons.eye
                                : FeatherIcons.eyeOff,
                            isObscure: isObscured,
                            onShowPassword: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            isPassword: true,
                            title: 'Password',
                            hintText: 'Enter your password',
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter Password !";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomTextButton(
                                text: "Forget Password ?",
                                onTap: () {},
                              ),
                            ],
                          ),
                          SizedBox(height: 60),

                          PrimaryButton(
                            text: "Log In",
                            backgroundColor: AppColors.blackColor,
                            textColor: AppColors.whiteColor,
                            isLoading: isLoginLoading,
                            onTap: () async {
                              if (!formKey.currentState!.validate()) return;
                              setState(() {
                                isLoginLoading = true;
                              });
                              final result = await AuthController()
                                  .loginWithEmailPassword(
                                    emailController.text,
                                    passwordController.text,
                                  );
                              setState(() {
                                isLoginLoading = false;
                              });
                              if (result["success"]) {
                                context.goNamed("mainScreen");
                              } else {
                                UserFeedback.showErrorSnackbar(
                                  context,
                                  result["message"],
                                );
                              }
                            },
                          ),
                          SizedBox(height: 20),

                          CustomDivider(),
                          SizedBox(height: 20),

                          GoogleLoginButton(
                            isLoading: isGoogleLoginLoading,
                            text: "Log in With Google",
                            onTap: () async {
                              setState(() {
                                isGoogleLoginLoading = true;
                              });
                              final result = await AuthController()
                                  .logInWithGoogle();

                              if (!mounted) return; // Check BEFORE setState

                              setState(() {
                                isGoogleLoginLoading = false;
                              });

                              if (result['success']) {
                                if (!mounted) return; // Check BEFORE navigation
                                context.goNamed("mainScreen");
                              } else {
                                if (!mounted)
                                  return; // Check BEFORE showing snackbar
                                UserFeedback.showErrorSnackbar(
                                  context,
                                  result['message'] ?? 'Login failed',
                                );
                              }
                            },
                          ),
                          Spacer(),
                          Center(
                            child: CustomTextButton(
                              text: "Don't have an account? Create One",
                              onTap: () {
                                context.goNamed("signup");
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