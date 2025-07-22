import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/pages/users/widgets/addNewUserButton.dart';

class AppAppbar extends StatefulWidget implements PreferredSizeWidget {
  const AppAppbar({super.key});

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
    final dangerColor = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    return AppBar(
      backgroundColor: backgroundColor,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: AddNewUserButton(),
        ),
      ],
    );
  }
}
