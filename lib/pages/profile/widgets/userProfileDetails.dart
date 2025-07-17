import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';

class UserProfileDetails extends StatefulWidget {
  const UserProfileDetails({super.key});

  @override
  State<UserProfileDetails> createState() => _UserProfileDetailsState();
}

class _UserProfileDetailsState extends State<UserProfileDetails> {
  bool isPageLoading = false;
  final UserController _userController = UserController();
  var _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isPageLoading = true;
    });
    await getCurrentUserFromLocalStorage();
    setState(() {
      isPageLoading = false;
    });
  }

  Future<void> getCurrentUserFromLocalStorage() async {
    final currentUser = await _userController.getCurrentUserFromLocalStorage();
    setState(() {
      _currentUser = currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return isPageLoading
        ? const AppSpinner()
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.envelope_fill, color: textColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentUser != null ? _currentUser.email : "",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(CupertinoIcons.phone_fill, color: textColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentUser != null ? _currentUser.phoneNumber : "",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
          ],
        );
  }
}
