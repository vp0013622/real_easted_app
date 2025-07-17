import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/property/FeaturesModel.dart';

class PropertyFeaturesSection extends StatelessWidget {
  final Features features;

  const PropertyFeaturesSection({Key? key, required this.features})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;

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
            'Key Features',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureItem(
                context,
                Icons.hotel_outlined,
                '${features.bedRooms}',
                'Bedrooms',
              ),
              _buildFeatureItem(
                context,
                Icons.bathtub_outlined,
                '${features.bathRooms}',
                'Bathrooms',
              ),
              _buildFeatureItem(
                context,
                Icons.space_dashboard_outlined,
                '${features.areaInSquarFoot}',
                'Sq Ft',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.brandSecondary.withOpacity(0.1)
                    : AppColors.brandPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.brandSecondary
                    : AppColors.brandPrimary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.greyColor),
        ),
      ],
    );
  }
}
