import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class PropertyTypeContainer extends StatefulWidget {
  final bool isActive;
  final String type;
  const PropertyTypeContainer(
      {super.key, required this.isActive, required this.type});

  @override
  State<PropertyTypeContainer> createState() => _PropertyTypeContainerState();
}

class _PropertyTypeContainerState extends State<PropertyTypeContainer> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBackgroundColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final brandShadowColor =
        isDark ? AppColors.brandSecondary : AppColors.brandPrimary;
    final brandSecondaryShadowColor =
        isDark ? AppColors.darkShadowColor : AppColors.lightShadowColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final activePropertyTypeContainerBackgroundColor =
        isDark ? AppColors.darkCardBackground : AppColors.darkCardBackground;
    const activePropertyTypeContainerTextColor = AppColors.darkWhiteText;
    return Container(
      padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: widget.isActive
            ? activePropertyTypeContainerBackgroundColor
            : backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color:
                widget.isActive ? brandSecondaryShadowColor : backgroundColor,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        widget.type,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color:
                  widget.isActive ? activePropertyTypeContainerTextColor : null,
            ),
      ),
    );
  }
}
