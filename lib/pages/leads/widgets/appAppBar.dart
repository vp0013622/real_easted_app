import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class LeadsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const LeadsAppBar({super.key, this.actions});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      title: Text(
        'Leads',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
