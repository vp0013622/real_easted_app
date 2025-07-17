import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class ProfileListTile extends StatefulWidget {
  final String path;
  final IconData icon;
  final String title;
  final int? trailingNumberLabel;
  final Color? color;
  final bool showBottomRadius;

  const ProfileListTile({
    super.key,
    required this.path,
    required this.icon,
    required this.title,
    this.trailingNumberLabel,
    this.color,
    this.showBottomRadius = false,
  });

  @override
  State<ProfileListTile> createState() => _ProfileListTileState();
}

class _ProfileListTileState extends State<ProfileListTile> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white70 : Colors.black87;
    final textColor = widget.color ?? defaultColor;
    final brandColor =
        isDark ? AppColors.brandSecondary : AppColors.brandPrimary;

    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, widget.path);
      },
      shape:
          widget.showBottomRadius
              ? const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              )
              : null,
      leading: Icon(widget.icon, color: textColor),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: textColor),
          ),
          if (widget.trailingNumberLabel != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.trailingNumberLabel.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: brandColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: const Icon(
        CupertinoIcons.chevron_right,
        color: AppColors.greyColor,
        size: 16,
      ),
    );
  }
}
