import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/providers/theme_provider.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final bool isExpanded;
  final VoidCallback? onTap;

  const SettingsSection({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    required this.child,
    this.isExpanded = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.currentTheme == 'dark';
        final cardColor = isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground;
        final textColor =
            isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
        final subtitleColor = isDark
            ? AppColors.darkWhiteText.withOpacity(0.7)
            : Colors.grey[600];
        final chevronColor = isDark
            ? AppColors.darkWhiteText.withOpacity(0.5)
            : Colors.grey[400];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (iconColor ?? Colors.blue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (onTap != null)
                          Icon(
                            Icons.chevron_right,
                            color: chevronColor,
                          ),
                      ],
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 16),
                      child,
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
