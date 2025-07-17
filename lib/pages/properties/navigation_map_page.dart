import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import 'package:inhabit_realties/services/map/mapService.dart';
import 'package:inhabit_realties/services/map/mapRedirectionService.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';

class NavigationMapPage extends StatefulWidget {
  final Address propertyAddress;
  final String propertyName;

  const NavigationMapPage({
    Key? key,
    required this.propertyAddress,
    required this.propertyName,
  }) : super(key: key);

  @override
  State<NavigationMapPage> createState() => _NavigationMapPageState();
}

class _NavigationMapPageState extends State<NavigationMapPage>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  LatLng? _propertyLocation;
  List<LatLng> _routePoints = [];
  List<LatLng> _animatedRoutePoints = [];
  bool _isLoading = true;
  bool _isLoadingRoute = false;
  bool _isAnimating = false;
  bool _isDirectionsMode = false;
  String _distance = '';
  String _duration = '';
  String _errorMessage = '';
  StreamSubscription<Position>? _positionStream;

  // Animation controllers
  late AnimationController _routeAnimationController;
  late AnimationController _cameraAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _routeAnimation;
  late Animation<double> _cameraAnimation;
  late Animation<double> _pulseAnimation;

  // Location details
  String? _selectedLocationName;
  String? _selectedLocationAddress;
  bool _showLocationDetails = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _routeAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _cameraAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _routeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _routeAnimationController,
      curve: Curves.easeInOut,
    ));

    _cameraAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cameraAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get current location first (most important)
      final position = await MapService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
      } else {
        // Don't return here, continue with property location
      }

      // Get property coordinates
      final propertyCoords = await MapService.getCoordinatesFromAddress(
        widget.propertyAddress,
      );

      if (propertyCoords != null) {
        setState(() {
          _propertyLocation = propertyCoords;
        });
      } else {
        setState(() {
          _errorMessage =
              'Could not find the property location on the map. Please check the address.';
        });
        return;
      }

      // Set error message if no current location but property location is available
      if (_currentPosition == null) {
        setState(() {
          _errorMessage =
              'Could not get your current location. Showing property location only. Please enable location services for navigation.';
        });
      }

      // Get route if both locations are available
      if (_currentPosition != null && _propertyLocation != null) {
        await _getRoute();

        // Start the route animation after a short delay
        if (_routePoints.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _startRouteAnimation();
          });
        }
      }

      // Start location tracking only if we have current location
      if (_currentPosition != null) {
        _startLocationTracking();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading map: $e';
      });
    }
  }

  void _startRouteAnimation() {
    if (_routePoints.isEmpty || _isAnimating) return;

    setState(() {
      _isAnimating = true;
      _animatedRoutePoints = [];
    });

    // Start the route animation
    _routeAnimationController.forward();

    // Listen to animation updates
    _routeAnimationController.addListener(() {
      final progress = _routeAnimation.value;
      final pointCount = (_routePoints.length * progress).round();

      setState(() {
        _animatedRoutePoints = _routePoints.take(pointCount).toList();
      });
    });

    // Start camera animation after route animation
    _routeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startCameraAnimation();
      }
    });
  }

  void _startCameraAnimation() {
    if (_currentPosition == null || _propertyLocation == null) return;

    // Animate camera from current location to property location
    _cameraAnimationController.forward();

    _cameraAnimationController.addListener(() {
      final progress = _cameraAnimation.value;
      final startLat = _currentPosition!.latitude;
      final startLng = _currentPosition!.longitude;
      final endLat = _propertyLocation!.latitude;
      final endLng = _propertyLocation!.longitude;

      final currentLat = startLat + (endLat - startLat) * progress;
      final currentLng = startLng + (endLng - startLng) * progress;

      _mapController.move(
        LatLng(currentLat, currentLng),
        _mapController.zoom,
      );
    });

    _cameraAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });

        // Fit bounds to show both locations
        Future.delayed(const Duration(milliseconds: 500), () {
          _fitBounds();
        });
      }
    });
  }

  Future<void> _getRoute() async {
    if (_currentPosition == null || _propertyLocation == null) return;

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final route = await MapService.getRoute(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _propertyLocation!,
      );

      if (route != null) {
        final geometry = route['geometry'];
        if (geometry['type'] == 'LineString') {
          final coordinates = geometry['coordinates'] as List;
          final points = coordinates.map((coord) {
            return LatLng(coord[1] as double, coord[0] as double);
          }).toList();

          setState(() {
            _routePoints = points;
            _distance = MapService.formatDistance(route['distance']);
            _duration = MapService.formatDuration(route['duration']);
          });
        }
      }
    } catch (e) {
    } finally {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  void _startLocationTracking() {
    // Remove real-time tracking - just get initial location once
    // This prevents constant updates and battery drain
  }

  void _startPulseAnimation() {
    // Only start pulse animation in directions mode
    if (_isDirectionsMode) {
      _pulseAnimationController.repeat(reverse: true);
    }
  }

  void _displayLocationDetails(String locationType) async {
    String locationName = '';
    String locationAddress = '';

    if (locationType == 'current') {
      locationName = 'Your Location';
      try {
        final address = await MapService.getAddressFromCoordinates(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        );
        locationAddress = address ?? 'Current location';
      } catch (e) {
        locationAddress = 'Current location';
      }
    } else if (locationType == 'property') {
      locationName = widget.propertyName;
      locationAddress =
          '${widget.propertyAddress.street}, ${widget.propertyAddress.area}, ${widget.propertyAddress.city}, ${widget.propertyAddress.state}';
    }

    setState(() {
      _selectedLocationName = locationName;
      _selectedLocationAddress = locationAddress;
      _showLocationDetails = true;
    });

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showLocationDetails = false;
        });
      }
    });
  }

  void _startDirectionsMode() {
    if (_currentPosition == null || _propertyLocation == null) {
      // Show error if no current location
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Unable to get your current location. Please enable location services.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDirectionsMode = true;
    });

    // Start real-time location tracking
    _startRealTimeTracking();

    // Start pulse animation for directions mode
    _startPulseAnimation();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Directions mode activated! Follow the route to your destination.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _stopDirectionsMode() {
    setState(() {
      _isDirectionsMode = false;
    });

    // Stop real-time tracking
    _positionStream?.cancel();
    _positionStream = null;

    // Stop pulse animation
    _pulseAnimationController.stop();

    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Directions mode deactivated.'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _startRealTimeTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters for better precision
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });

      // Update route in real-time
      if (_propertyLocation != null) {
        _getRoute();
      }
    }, onError: (error) {});
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    _routeAnimationController.dispose();
    _cameraAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(child: AppSpinner())
          : _errorMessage.isNotEmpty && _propertyLocation == null
              ? _buildErrorView()
              : Stack(
                  children: [
                    // Map
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        // Prioritize current location for initial center
                        initialCenter: _currentPosition != null
                            ? LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude)
                            : _propertyLocation ??
                                const LatLng(20.5937,
                                    78.9629), // Default to India center
                        initialZoom: _currentPosition != null &&
                                _propertyLocation != null
                            ? 12
                            : 15,
                        onMapReady: () {
                          if (_currentPosition != null &&
                              _propertyLocation != null) {
                            _fitBounds();
                          }
                        },
                      ),
                      children: [
                        // OpenStreetMap tiles with theme support
                        TileLayer(
                          urlTemplate: isDark
                              ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.inhabit.realties',
                          maxZoom: 19,
                          subdomains:
                              isDark ? ['a', 'b', 'c', 'd'] : ['a', 'b', 'c'],
                        ),
                        // Animated route polyline
                        if (_animatedRoutePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _animatedRoutePoints,
                                strokeWidth: 4,
                                color: AppColors.brandPrimary,
                              ),
                            ],
                          ),
                        // Static route polyline (for reference)
                        if (_routePoints.isNotEmpty && !_isAnimating)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                strokeWidth: 4,
                                color: AppColors.brandPrimary,
                              ),
                            ],
                          ),
                        // Moving dot animation along the route
                        if (_isAnimating && _animatedRoutePoints.isNotEmpty)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _animatedRoutePoints.last,
                                width: 20,
                                height: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.brandPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isDark ? Colors.black : Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.brandPrimary
                                            .withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // Markers
                        MarkerLayer(
                          markers: [
                            // Current location marker with static ring
                            if (_currentPosition != null)
                              Marker(
                                point: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                width: 60,
                                height: 60,
                                rotate: true,
                                child: GestureDetector(
                                  onTap: () =>
                                      _displayLocationDetails('current'),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Pulsing ring (only in directions mode)
                                      if (_isDirectionsMode)
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (context, child) {
                                            return Container(
                                              width: 40 +
                                                  (_pulseAnimation.value * 20),
                                              height: 40 +
                                                  (_pulseAnimation.value * 20),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.brandPrimary
                                                      .withOpacity(0.3 -
                                                          (_pulseAnimation
                                                                  .value *
                                                              0.2)),
                                                  width: 2,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        // Static ring (when not in directions mode)
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.brandPrimary
                                                  .withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      // Location dot
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: AppColors.brandPrimary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.black
                                                : Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.my_location,
                                          color: isDark
                                              ? Colors.black
                                              : Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Property marker
                            if (_propertyLocation != null)
                              Marker(
                                point: _propertyLocation!,
                                width: 40,
                                height: 40,
                                rotate: true,
                                child: GestureDetector(
                                  onTap: () =>
                                      _displayLocationDetails('property'),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.lightSuccess,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color:
                                          isDark ? Colors.black : Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Top bar
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.propertyName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_distance.isNotEmpty &&
                                      _duration.isNotEmpty)
                                    Text(
                                      '$_distance • $_duration',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_isLoadingRoute || _isAnimating)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            // External maps button
                            GestureDetector(
                              onTap: () {
                                MapRedirectionService.showMapOptions(
                                  context: context,
                                  propertyAddress: widget.propertyAddress,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.map,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Maps',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            // Directions button
                            GestureDetector(
                              onTap: () {
                                if (_isDirectionsMode) {
                                  _stopDirectionsMode();
                                } else {
                                  _startDirectionsMode();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _isDirectionsMode
                                      ? Colors.red.withOpacity(0.9)
                                      : Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isDirectionsMode
                                          ? Icons.stop
                                          : Icons.directions,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isDirectionsMode ? 'Stop' : 'Directions',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
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
                    // Location warning banner (if no current location but property location exists)
                    if (_errorMessage.isNotEmpty && _propertyLocation != null)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 80,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Directions mode indicator
                    if (_isDirectionsMode)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 80,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Directions mode active - Following route to destination',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Bottom info card
                    if (_distance.isNotEmpty && _duration.isNotEmpty)
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCardBackground
                                : AppColors.lightCardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.route,
                                color: AppColors.brandPrimary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Route to Property',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkWhiteText
                                            : AppColors.lightDarkText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_distance • $_duration',
                                      style: TextStyle(
                                        color: AppColors.greyColor2,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.navigation,
                                color: AppColors.brandPrimary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Location details card
                    if (_showLocationDetails)
                      Positioned(
                        bottom: MediaQuery.of(context).padding.bottom +
                            (_distance.isNotEmpty ? 80 : 16),
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCardBackground
                                : AppColors.lightCardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.brandPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedLocationName ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark
                                            ? AppColors.darkWhiteText
                                            : AppColors.lightDarkText,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showLocationDetails = false;
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.greyColor2,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedLocationAddress ?? '',
                                style: TextStyle(
                                  color: AppColors.greyColor2,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.greyColor2,
            ),
            const SizedBox(height: 16),
            Text(
              'Map Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyColor2,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _initializeMap();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _fitBounds() {
    if (_currentPosition != null && _propertyLocation != null) {
      final bounds = LatLngBounds.fromPoints([
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _propertyLocation!,
      ]);
      _mapController.fitBounds(bounds,
          options: const FitBoundsOptions(padding: EdgeInsets.all(50)));
    }
  }
}
