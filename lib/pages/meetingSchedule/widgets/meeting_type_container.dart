import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class MeetingTypeContainer extends StatefulWidget {
  final bool isActive;
  final String type;
  const MeetingTypeContainer(
      {super.key, required this.isActive, required this.type});

  @override
  State<MeetingTypeContainer> createState() => _MeetingTypeContainerState();
}

class _MeetingTypeContainerState extends State<MeetingTypeContainer> {
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
    final activeMeetingTypeContainerBackgroundColor =
        isDark ? AppColors.darkCardBackground : AppColors.darkCardBackground;
    const activeMeetingTypeContainerTextColor = AppColors.darkWhiteText;
    return Container(
      padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: widget.isActive
            ? activeMeetingTypeContainerBackgroundColor
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
                  widget.isActive ? activeMeetingTypeContainerTextColor : null,
            ),
      ),
    );
  }
}
