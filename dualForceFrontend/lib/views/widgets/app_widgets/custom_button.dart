import 'package:flutter/material.dart';
import 'package:dual_force/res/app_colors.dart';

class CustomButton extends StatelessWidget {
  final Widget label;
  final IconData? icon;
  final double? iconSize;
  final Color? contentColor;
  final Color buttonColor;
  final void Function()? onPressed;

  const CustomButton(
      {super.key,
      required this.icon,
      this.iconSize,
      required this.label,
      this.buttonColor = AppColors.primaryYellow,
      required this.onPressed,
      this.contentColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon:icon!=null? Icon(
          icon,
          color: contentColor,
          size: iconSize,
        ):null,
        label: label,
        style: ElevatedButton.styleFrom(
          elevation: 10,
          shadowColor: AppColors.shadowColor,
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
