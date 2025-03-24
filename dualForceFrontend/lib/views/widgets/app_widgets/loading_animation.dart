import 'package:flutter/material.dart';
import 'package:dual_force/res/app_colors.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: AppColors.shadowColor,
      child: Center(
        child: Lottie.asset('assets/lottie/loading.json',
        height: 100),
      ),
    );
  }
}