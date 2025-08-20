import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/widgets/notification_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAppbar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onToggleTheme;
  const AppAppbar({super.key, this.onToggleTheme});

  @override
  State<AppAppbar> createState() => _AppappbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppappbarState extends State<AppAppbar> {
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole();
  }

  Future<void> _loadCurrentUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString('currentUser');

      if (currentUserJson != null) {
        final userData = json.decode(currentUserJson);
        _currentUserRole = userData['role']?['name'] ??
            userData['role'] ??
            userData['roleId']?['name'] ??
            userData['roleId'];

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

    bool _canCreateMeetings() {
    if (_currentUserRole == null) {
      return false;
    }
    
    final role = _currentUserRole!.toLowerCase();
    final canCreate = role == 'admin' || role == 'sales' || role == 'executive';
    
    return canCreate;
  }

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
        const NotificationBadgeWithLoading(),
        const SizedBox(width: 8), // Add some padding at the end
      ],
    );
  }
}
