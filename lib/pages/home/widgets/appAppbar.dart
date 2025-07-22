import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class AppAppbar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onToggleTheme;
  const AppAppbar({super.key, this.onToggleTheme});

  @override
  State<AppAppbar> createState() => _AppappbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppappbarState extends State<AppAppbar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return AppBar(
      backgroundColor: backgroundColor,
      iconTheme: IconThemeData(color: textColor),
      actions: [
        //theme toggle button
        IconButton(
          icon: isDark
              ? const Icon(CupertinoIcons.moon_fill)
              : const Icon(CupertinoIcons.sun_max_fill),
          onPressed: () {
            widget.onToggleTheme?.call();
          },
        ),
        //notifications
        IconButton(icon: const Icon(CupertinoIcons.bell), onPressed: () {}),
        const SizedBox(width: 8), // Add some padding at the end
      ],
    );
  }
}
