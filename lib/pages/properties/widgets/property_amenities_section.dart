import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/property/FeaturesModel.dart';

class PropertyAmenitiesSection extends StatelessWidget {
  final Features features;

  const PropertyAmenitiesSection({Key? key, required this.features})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;

    if (features.amenities.isEmpty) {
      return Container(); // Return empty container if no amenities
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amenities',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: features.amenities.map((amenity) {
              return _buildAmenityItem(context, amenity);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityItem(BuildContext context, String amenity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.brandSecondary.withOpacity(0.1)
            : AppColors.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: isDark ? AppColors.brandSecondary : AppColors.brandPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              amenity,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkWhiteText
                        : AppColors.lightDarkText,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
