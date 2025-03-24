import 'dart:async';
import 'dart:developer';
import 'package:dual_force/views/screens/homescreen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:dual_force/res/app_colors.dart';
import 'package:dual_force/res/app_text_style.dart';
import 'package:dual_force/utils/navigation/routes/slide_route.dart';
import 'package:dual_force/viewmodels/auth_viewmodel.dart';
import 'package:dual_force/views/screens/auth/sign_up/sign_up_screen.dart';
import 'package:dual_force/views/widgets/app_widgets/custom_button.dart';
import 'package:dual_force/views/widgets/app_widgets/loading_animation.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                          const Text('Welcome back',
                              style: AppTextStyle.largeTextStyle),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          const Text('Log in to your account to continue',
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

                          // Forgot Password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text('Forgot Password?',
                                  style: AppTextStyle.mediumTextStyle),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),

                          // Login button
                          CustomButton(
                              icon: null,
                              label: Text(
                                "Log in",
                                style: AppTextStyle.titleTextStyle
                                    .copyWith(color: Colors.black),
                              ),
                              onPressed: () async {
                                viewmodel.setisLoading(true);
                                await viewmodel.login().then((val) {
                                  if (val) {
                                    viewmodel.setisLoading(false);
                                    Navigator.pushReplacement(
                                        context,
                                        SlideRoute(
                                            page: Homescreen( userId: viewmodel.currentUser?.id??''),
                                            direction: AxisDirection.right));
                                  }
                                }).onError((error, stck) {
                                  log(error.toString());
                                  viewmodel.setisLoading(false);
                                });
                              }),
                          SizedBox(height: constraints.maxHeight * 0.02),

                          // Sign up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account? ',
                                style: AppTextStyle.mediumTextStyle,
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushReplacement(
                                    context,
                                    SlideRoute(
                                        page: SignUpScreen(),
                                        direction: AxisDirection.down,
                                        duration: Durations.long3)),
                                child: Text('Sign Up',
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
