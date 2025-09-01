import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class HorizontalFilterBar extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final Function(int) onFilterChanged;
  final String? title;
  final String? subtitle;

  const HorizontalFilterBar({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterChanged,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final subtitleColor = Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: subtitleColor,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
        Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 8,
                  right: index == filters.length - 1 ? 20 : 8,
                ),
                child: InkWell(
                  onTap: () => onFilterChanged(index),
                  child: _FilterChip(
                    label: filters[index],
                    isActive: index == selectedIndex,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _FilterChip({
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final activeBackgroundColor = isDark ? AppColors.darkCardBackground : AppColors.darkCardBackground;
    final activeTextColor = AppColors.darkWhiteText;
    final brandSecondaryShadowColor = isDark ? AppColors.darkShadowColor : AppColors.lightShadowColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: isActive ? activeBackgroundColor : backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: isActive ? brandSecondaryShadowColor : backgroundColor,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: isActive ? activeTextColor : null,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
