import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:inhabit_realties/constants/contants.dart';

class TestMapPage extends StatefulWidget {
  const TestMapPage({Key? key}) : super(key: key);

  @override
  State<TestMapPage> createState() => _TestMapPageState();
}

class _TestMapPageState extends State<TestMapPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Test Map'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(37.7749, -122.4194), // San Francisco
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.inhabit.realties',
            maxZoom: 19,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(37.7749, -122.4194),
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
