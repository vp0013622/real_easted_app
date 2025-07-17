import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import 'package:inhabit_realties/pages/properties/navigation_map_page.dart';
import 'package:inhabit_realties/services/map/mapRedirectionService.dart';

class PropertyLocationSection extends StatelessWidget {
  final Address address;
  final String propertyName;

  const PropertyLocationSection({
    Key? key,
    required this.address,
    required this.propertyName,
  }) : super(key: key);

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
            'Location',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Address details
          _buildAddressRow(context, Icons.location_on_outlined, address.street),
          const SizedBox(height: 8),
          _buildAddressRow(
            context,
            Icons.location_city_outlined,
            '${address.area}, ${address.city}',
          ),
          const SizedBox(height: 8),
          _buildAddressRow(
            context,
            Icons.map_outlined,
            '${address.state}, ${address.zipOrPinCode}',
          ),
          const SizedBox(height: 8),
          _buildAddressRow(context, Icons.flag_outlined, address.country),
          const SizedBox(height: 16),
          // Map redirection buttons
          _buildMapRedirectionButtons(context, isDark),
          const SizedBox(height: 16),
          // Small map preview
          _buildMapPreview(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context, bool isDark) {
    // Check if we have valid coordinates
    final hasValidLocation =
        address.location.lat != 0 && address.location.lng != 0;

    if (!hasValidLocation) {
      // Fallback to button if no valid location
      return _buildFallbackButton(context, isDark);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationMapPage(
              propertyAddress: address,
              propertyName: propertyName,
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.greyColor2.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Map
              FlutterMap(
                options: MapOptions(
                  initialCenter:
                      LatLng(address.location.lat, address.location.lng),
                  initialZoom: 15,
                  interactiveFlags:
                      InteractiveFlag.none, // Disable interactions
                ),
                children: [
                  // Map tiles
                  TileLayer(
                    urlTemplate: isDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.inhabit.realties',
                    maxZoom: 19,
                    subdomains: isDark ? ['a', 'b', 'c', 'd'] : ['a', 'b', 'c'],
                  ),
                  // Property marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point:
                            LatLng(address.location.lat, address.location.lng),
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightSuccess,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.black : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: isDark ? Colors.black : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Overlay with location details
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        propertyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${address.area}, ${address.city}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tap indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to view',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackButton(BuildContext context, bool isDark) {
    final brandColor =
        isDark ? AppColors.brandSecondary : AppColors.brandPrimary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationMapPage(
              propertyAddress: address,
              propertyName: propertyName,
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: brandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: brandColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
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
                'Tap to see location',
                style: TextStyle(
                  color: brandColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapRedirectionButtons(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              MapRedirectionService.showMapOptions(
                context: context,
                propertyAddress: address,
              );
            },
            icon: const Icon(Icons.directions, size: 18),
            label: const Text('Get Directions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NavigationMapPage(
                    propertyAddress: address,
                    propertyName: propertyName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('View Map'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.brandSecondary : AppColors.brandPrimary,
              side: BorderSide(
                color: isDark ? AppColors.brandSecondary : AppColors.brandPrimary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.greyColor2),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.greyColor2),
          ),
        ),
      ],
    );
  }
}
