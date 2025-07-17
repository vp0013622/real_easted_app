import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/constants/profileMenuList.dart';
import 'package:inhabit_realties/pages/profile/widgets/profileListTile.dart';

class ProfileMenuListView extends StatefulWidget {
  final int assignedLeadsCount;
  const ProfileMenuListView({super.key, required this.assignedLeadsCount});

  @override
  State<ProfileMenuListView> createState() => _ProfileMenuListViewState();
}

class _ProfileMenuListViewState extends State<ProfileMenuListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: ProfileMenuList.list.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = ProfileMenuList.list[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isLastItem = index == ProfileMenuList.list.length - 1;
        final isLogout = item['path'] == '/auth/logout';
        final defaultColor = isDark ? Colors.white70 : Colors.black87;

        // If this is the Assigned Leads item, use the real count
        int? trailingNumberLabel = item['title'] == 'Assigned Leads'
            ? widget.assignedLeadsCount
            : item['trailingNumberLabel'];

        return ProfileListTile(
          path: item['path'],
          icon: item['icon'],
          title: item['title'],
          trailingNumberLabel: trailingNumberLabel,
          color: isLogout
              ? (isDark ? AppColors.darkDanger : AppColors.lightDanger)
              : defaultColor,
          showBottomRadius: isLastItem,
        );
      },
    );
  }
}
