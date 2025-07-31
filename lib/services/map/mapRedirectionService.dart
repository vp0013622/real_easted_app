import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import '../../pages/widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class MapRedirectionService {
  /// Redirect to Google Maps with directions from current location to property
  static Future<bool> redirectToGoogleMaps(Address propertyAddress) async {
    try {
      // Get current location
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Build the destination address
      final destinationAddress = _buildAddressString(propertyAddress);

      // Create Google Maps URL with directions - try multiple formats for better compatibility
      final url1 = Uri.parse('https://www.google.com/maps/dir/'
          '${currentPosition.latitude},${currentPosition.longitude}/'
          '${Uri.encodeComponent(destinationAddress)}');

      final url2 = Uri.parse('https://maps.google.com/maps?daddr='
          '${Uri.encodeComponent(destinationAddress)}'
          '&saddr=${currentPosition.latitude},${currentPosition.longitude}');

      // Try first format
      bool launched = await _launchUrl(url1);

      // If first format fails, try second format
      if (!launched) {
        launched = await _launchUrl(url2);
      }

      return launched;
    } catch (e) {
      // If current location fails, just show the destination
      return await _redirectToGoogleMapsDestination(propertyAddress);
    }
  }

  /// Redirect to Google Maps showing only the destination
  static Future<bool> _redirectToGoogleMapsDestination(
      Address propertyAddress) async {
    try {
      final destinationAddress = _buildAddressString(propertyAddress);

      // Try multiple Google Maps URL formats for better compatibility
      final url1 = Uri.parse('https://www.google.com/maps/search/'
          '${Uri.encodeComponent(destinationAddress)}');

      final url2 = Uri.parse('https://maps.google.com/maps?q='
          '${Uri.encodeComponent(destinationAddress)}');

      // Try first format
      bool launched = await _launchUrl(url1);

      // If first format fails, try second format
      if (!launched) {
        launched = await _launchUrl(url2);
      }

      return launched;
    } catch (e) {
      return false;
    }
  }

  /// Redirect to Apple Maps with directions (iOS only)
  static Future<bool> redirectToAppleMaps(Address propertyAddress) async {
    if (!Platform.isIOS) {
      return false; // Apple Maps only available on iOS
    }

    try {
      // Get current location
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Build the destination address
      final destinationAddress = _buildAddressString(propertyAddress);

      // Create Apple Maps URL with directions
      final url = Uri.parse('http://maps.apple.com/?saddr='
          '${currentPosition.latitude},${currentPosition.longitude}'
          '&daddr=${Uri.encodeComponent(destinationAddress)}'
          '&dirflg=d' // driving directions
          );

      return await _launchUrl(url);
    } catch (e) {
      // If current location fails, just show the destination
      return await _redirectToAppleMapsDestination(propertyAddress);
    }
  }

  /// Redirect to Apple Maps showing only the destination
  static Future<bool> _redirectToAppleMapsDestination(
      Address propertyAddress) async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final destinationAddress = _buildAddressString(propertyAddress);
      final url = Uri.parse(
          'http://maps.apple.com/?q=${Uri.encodeComponent(destinationAddress)}');

      return await _launchUrl(url);
    } catch (e) {
      return false;
    }
  }

  /// Build address string from Address model
  static String _buildAddressString(Address address) {
    final parts = <String>[];

    if (address.street.isNotEmpty) parts.add(address.street);
    if (address.area.isNotEmpty) parts.add(address.area);
    if (address.city.isNotEmpty) parts.add(address.city);
    if (address.state.isNotEmpty) parts.add(address.state);
    if (address.zipOrPinCode.isNotEmpty) parts.add(address.zipOrPinCode);
    if (address.country.isNotEmpty) parts.add(address.country);

    return parts.join(', ');
  }

  /// Launch URL with error handling
  static Future<bool> _launchUrl(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      // Try alternative launch mode for Android
      try {
        return await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );
      } catch (e2) {
        return false;
      }
    }
  }

  /// Show map options dialog
  static Future<void> showMapOptions({
    required BuildContext context,
    required Address propertyAddress,
  }) async {
    final isIOS = Platform.isIOS;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Open in Maps',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),

            // Google Maps option
            ListTile(
              leading: const Icon(Icons.map, color: Colors.red),
              title: const Text('Google Maps'),
              subtitle: const Text('Get directions with Google Maps'),
              onTap: () async {
                Navigator.pop(context);
                final success = await redirectToGoogleMaps(propertyAddress);
                if (!success && context.mounted) {
                  AppSnackBar.showSnackBar(
                    context,
                    'Error',
                    'Could not open Google Maps',
                    ContentType.failure,
                  );
                }
              },
            ),

            // Apple Maps option (iOS only)
            if (isIOS)
              ListTile(
                leading: const Icon(Icons.map_outlined, color: Colors.blue),
                title: const Text('Apple Maps'),
                subtitle: const Text('Get directions with Apple Maps'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await redirectToAppleMaps(propertyAddress);
                  if (!success && context.mounted) {
                    AppSnackBar.showSnackBar(
                      context,
                      'Error',
                      'Could not open Apple Maps',
                      ContentType.failure,
                    );
                  }
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
