import 'package:flutter/material.dart';
import 'package:inhabit_realties/pages/home/home_page.dart';
import 'package:inhabit_realties/pages/leads/leads_page.dart';
import 'package:inhabit_realties/pages/profile/profile_page.dart';
import 'package:inhabit_realties/pages/properties/properties_page.dart';
import 'package:inhabit_realties/pages/reports/reports_page.dart';
import 'package:inhabit_realties/pages/widgets/app_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const MainLayout({Key? key, this.onToggleTheme}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(onToggleTheme: () => widget.onToggleTheme?.call()),
      const PropertiesPage(),
      const LeadsPage(),
      const ReportsPage(),
      const ProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
