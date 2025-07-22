import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';

class AppBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animations = List.generate(5, (index) {
      final curved = CurvedAnimation(
        parent: _controller,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
      );
      return Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkCardBackground : Colors.white;
    final selectedColor =
        isDark ? AppColors.darkPrimary : AppColors.brandPrimary;
    final unselectedColor = isDark ? Colors.grey[500] : Colors.grey;
    final shadowColor = isDark ? Colors.black54 : Colors.black12;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: widget.currentIndex,
            onTap: widget.onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: selectedColor,
            unselectedItemColor: unselectedColor,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              height: 1.5,
            ),
            items: [
              _buildNavItem(
                context,
                icon: CupertinoIcons.house_fill,
                label: 'Home',
                index: 0,
                animation: _animations[0],
              ),
              _buildNavItem(
                context,
                icon: CupertinoIcons.building_2_fill,
                label: 'Properties',
                index: 1,
                animation: _animations[1],
              ),
              _buildNavItem(
                context,
                icon: CupertinoIcons.person_2_fill,
                label: 'Leads',
                index: 2,
                animation: _animations[2],
              ),
              _buildNavItem(
                context,
                icon: CupertinoIcons.calendar,
                label: 'Meetings',
                index: 3,
                animation: _animations[3],
              ),
              _buildNavItem(
                context,
                icon: CupertinoIcons.person_crop_circle_fill,
                label: 'Profile',
                index: 4,
                animation: _animations[4],
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required Animation<double> animation,
  }) {
    final isSelected = widget.currentIndex == index;

    return BottomNavigationBarItem(
      icon: Transform.translate(
        offset: Offset(0, animation.value * (isSelected ? -4 : 0)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(icon, size: isSelected ? 26 : 24),
        ),
      ),
      label: label,
    );
  }
}
