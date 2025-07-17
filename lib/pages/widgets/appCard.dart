import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class AppCard extends StatefulWidget {
  Widget widget;
  AppCard({super.key, required this.widget});

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBackgroundColor = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final brandShadowColor = isDark ? AppColors.brandSecondary : AppColors.brandPrimary;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final brandSecondaryShadowColor = isDark ? AppColors.darkShadowColor : AppColors.lightShadowColor;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.circular(15),
        color: cardBackgroundColor,
        boxShadow: [
          BoxShadow(
              spreadRadius: 1,
              blurRadius: 2,
              color: brandSecondaryShadowColor,
              offset: const Offset(0, 0),
          ),
          
        ]
      ),
      child: widget.widget ,
    );
  }
}