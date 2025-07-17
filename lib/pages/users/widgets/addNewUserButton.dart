// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class AddNewUserButton extends StatefulWidget {
  const AddNewUserButton({super.key});

  @override
  State<AddNewUserButton> createState() => _AddNewUserButtonState();
}

class _AddNewUserButtonState extends State<AddNewUserButton> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.lightDarkText : AppColors.lightBackground;
    final cardBackgroundColor = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final brandShadowColor = isDark ? AppColors.brandSecondary : AppColors.brandPrimary;
    final brandSecondaryShadowColor = isDark ? AppColors.darkShadowColor : AppColors.lightShadowColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final activePropertyTypeContainerBackgroundColor = isDark ? AppColors.darkCardBackground : AppColors.darkCardBackground;
    const activePropertyTypeContainerTextColor = AppColors.darkWhiteText;
    final textColor = isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final shadowColor = isDark ?AppColors.lightCardBackground :AppColors.darkCardBackground;
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, '/auth/register');
      },
      child: Container(
      padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              offset: const Offset(0,0),
              color: shadowColor.withOpacity(0.3)
            ),
          ],
        ),
        child: Text(
          "Add User",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: textColor,
          ),
        ),
      )
    );
  }
}