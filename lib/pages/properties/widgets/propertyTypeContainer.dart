import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class PropertyTypeContainer extends StatefulWidget {
  final bool isActive;
  final String propertyType;
  const PropertyTypeContainer({
    super.key,
    required this.isActive,
    required this.propertyType,
  });

  @override
  State<PropertyTypeContainer> createState() => _PropertyTypeContainerState();
}

class _PropertyTypeContainerState extends State<PropertyTypeContainer> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:
            widget.isActive
                ? (isDark ? AppColors.brandSecondary : AppColors.brandPrimary)
                : (isDark
                    ? AppColors.darkCardBackground
                    : AppColors.lightCardBackground),
      ),
      child: Text(
        widget.propertyType,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color:
              widget.isActive
                  ? AppColors.darkWhiteText
                  : (isDark
                      ? AppColors.darkWhiteText
                      : AppColors.lightDarkText),
          fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
