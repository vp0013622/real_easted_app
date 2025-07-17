import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class Loader extends StatefulWidget {
  final double? size;
  final double? strokeWidth;

  const Loader({super.key, this.size = 24.0, this.strokeWidth = 2.0});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use AppColors based on theme
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final brandColor =
        isDark ? AppColors.brandSecondary : AppColors.brandPrimary;

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: CircularProgressIndicator(
        color: brandColor,
        strokeWidth: widget.strokeWidth!,
      ),
    );
  }
}
