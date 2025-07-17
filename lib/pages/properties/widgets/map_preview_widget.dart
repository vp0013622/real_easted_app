import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import 'package:inhabit_realties/pages/properties/navigation_map_page.dart';

class MapPreviewWidget extends StatelessWidget {
  final Address propertyAddress;
  final String propertyName;

  const MapPreviewWidget({
    Key? key,
    required this.propertyAddress,
    required this.propertyName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor =
        isDark ? AppColors.brandSecondary : AppColors.brandPrimary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationMapPage(
              propertyAddress: propertyAddress,
              propertyName: propertyName,
            ),
          ),
        );
      },
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: brandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: brandColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Map placeholder with gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    brandColor.withOpacity(0.1),
                    brandColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),
            // Map icon and text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: brandColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View on Map',
                    style: TextStyle(
                      color: brandColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get directions to this property',
                    style: TextStyle(
                      color: brandColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Navigation icon
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: brandColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
