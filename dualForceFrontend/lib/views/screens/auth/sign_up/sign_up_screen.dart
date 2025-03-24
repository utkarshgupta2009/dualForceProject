import 'dart:async';
import 'dart:developer';

import 'package:dual_force/views/screens/homescreen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:dual_force/res/app_colors.dart';
import 'package:dual_force/res/app_text_style.dart';
import 'package:dual_force/utils/navigation/routes/slide_route.dart';
import 'package:dual_force/viewmodels/auth_viewmodel.dart';
import 'package:dual_force/views/screens/auth/login/login_screen.dart';
import 'package:dual_force/views/widgets/app_widgets/custom_button.dart';
import 'package:dual_force/views/widgets/app_widgets/loading_animation.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<AuthViewmodel>(builder: (context, viewmodel, child) {
          return Stack(
            children: [
              LayoutBuilder(builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: constraints.maxHeight / 12,
                          ),
                          // Header text
                          const Text('Create an account',
                              style: AppTextStyle.largeTextStyle),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          const Text(
                              'Create your account - it takes less than a\nminute. Enter your email and password',
                              style: AppTextStyle.mediumTextStyle),
                          SizedBox(height: constraints.maxHeight * 0.03),

                          // Email field
                          TextField(
                            controller: viewmodel.emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),

                          // Password field
                          TextField(
                            controller: viewmodel.passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),

                          // Create Account button
                          CustomButton(
                              icon: null,
                              label: Text(
                                "Create Account",
                                style: AppTextStyle.titleTextStyle
                                    .copyWith(color: Colors.black),
                              ),
                              onPressed: () async {
                                viewmodel.setisLoading(true);
                                await viewmodel.signup().then((val) {
                                  if (val) {
                                    viewmodel.setisLoading(false);
                                    Navigator.pushReplacement(
                                        context,
                                        SlideRoute(
                                            page: Homescreen(
                                                userId: viewmodel
                                                        .currentUser?.id ??
                                                    ''),
                                            direction: AxisDirection.right));
                                  }
                                }).onError((error, stck) {
                                  log(error.toString());
                                  viewmodel.setisLoading(false);
                                });
                              }),
                          SizedBox(height: constraints.maxHeight * 0.02),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyle.mediumTextStyle,
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    SlideRoute(
                                        page: LoginScreen(),
                                        direction: AxisDirection.up,
                                        duration: Durations.long3)),
                                child: Text('Log in',
                                    style: AppTextStyle.subtitleTextStyle),
                              ),
                            ],
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (viewmodel.isLoading) LoadingAnimation(),
            ],
          );
        }),
      ),
    );
  }
}
