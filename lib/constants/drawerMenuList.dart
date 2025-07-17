import 'package:flutter/cupertino.dart';

class DrawerMenuList {
  static List<Map<String, dynamic>> list = [
    {'path': '/users', 'icon': CupertinoIcons.person_3_fill, 'title': 'Users'},
    {
      'path': '/documents/all',
      'icon': CupertinoIcons.doc_text_fill,
      'title': 'All Documents',
    },
    {
      'path': '/favorite_properties',
      'icon': CupertinoIcons.heart_fill,
      'title': 'My Favorite Properties',
    },
    {
      'path': '/reports',
      'icon': CupertinoIcons.doc_chart_fill,
      'title': 'Reports',
    },
    {
      'path': '/settings',
      'icon': CupertinoIcons.settings_solid,
      'title': 'Settings',
    },
    {
      'path': '/auth/register',
      'icon': CupertinoIcons.person_badge_plus_fill,
      'title': 'Register User',
    },
    {
      'path': '/auth/logout',
      'icon': CupertinoIcons.square_arrow_left_fill,
      'title': 'Logout',
    },
  ];
}
