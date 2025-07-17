import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsets padding;
  final CrossAxisAlignment alignment;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(20),
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).textTheme.headlineSmall?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.greyColor),
            ),
          ],
        ],
      ),
    );
  }
}
