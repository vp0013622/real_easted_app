import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/favoriteProperty/favoritePropertyController.dart';
import 'package:inhabit_realties/models/favoriteProperty/FavoritePropertyModel.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import 'package:inhabit_realties/services/property/propertyService.dart';
import 'package:inhabit_realties/pages/widgets/page_container.dart';
import 'package:inhabit_realties/pages/widgets/appDrawer.dart';
import 'package:inhabit_realties/pages/widgets/appCard.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_image_display.dart';
import 'package:inhabit_realties/pages/properties/property_details_page.dart';
import 'package:inhabit_realties/Enums/propertyStatusEnum.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePropertiesPage extends StatefulWidget {
  const FavoritePropertiesPage({super.key});

  @override
  State<FavoritePropertiesPage> createState() => _FavoritePropertiesPageState();
}

class _FavoritePropertiesPageState extends State<FavoritePropertiesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PropertyService _propertyService = PropertyService();

  bool _isLoading = true;
  bool _isInitialLoading = true;
  List<PropertyModel> _favoriteProperties = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteProperties();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteProperties() async {
    setState(() {
      _isLoading = true;
      _isInitialLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = context.read<FavoritePropertyController>();
      await controller.loadFavoriteProperties();

      if (mounted) {
        final favoriteProperties = controller.favoriteProperties;

        if (favoriteProperties.isNotEmpty) {
          // Get the actual property details for each favorite
          await _loadPropertyDetails(favoriteProperties);
        }

        setState(() {
          _isLoading = false;
          _isInitialLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load favorite properties: $e';
          _isLoading = false;
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadPropertyDetails(
      List<FavoritePropertyModel> favorites) async {
    try {
      final List<PropertyModel> properties = [];

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      for (final favorite in favorites) {
        try {
          final response = await _propertyService.getPropertyById(
              token, favorite.propertyId);
          if (response['statusCode'] == 200 && response['data'] != null) {
            final property = PropertyModel.fromJson(response['data']);
            properties.add(property);
          }
        } catch (e) {
          // Skip properties that can't be loaded
          continue;
        }
      }

      if (mounted) {
        setState(() {
          _favoriteProperties = properties;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _removeFromFavorites(String propertyId) async {
    try {
      final controller = context.read<FavoritePropertyController>();
      final success = await controller.removeFromFavorites(propertyId, context);

      if (success && mounted) {
        // Remove from local list
        setState(() {
          _favoriteProperties
              .removeWhere((property) => property.id == propertyId);
        });
      }
    } catch (e) {
      // Error handled by controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return PageContainer(
      title: 'My Favorite Properties',
      drawer: const AppDrawer(),
      children: [
        if (_isInitialLoading)
          _buildLoadingShimmer()
        else if (_errorMessage != null)
          _buildErrorWidget()
        else if (_favoriteProperties.isEmpty)
          _buildEmptyState()
        else
          _buildPropertiesList(),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: AppColors.lightDanger,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Favorites',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.lightDanger,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadFavoriteProperties,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.heart,
            size: 64,
            color: AppColors.greyColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorite Properties',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t added any properties to your favorites yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/properties'),
            icon: const Icon(Icons.search),
            label: const Text('Browse Properties'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _favoriteProperties.length,
        itemBuilder: (context, index) {
          final property = _favoriteProperties[index];
          return _buildPropertyCard(property);
        },
      ),
    );
  }

  Widget _buildPropertyCard(PropertyModel property) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;

    return GestureDetector(
      onTap: () {
        // Navigate to property details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsPage(property: property),
          ),
        );
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AppCard(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: screenHeight * 0.22,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: PropertyImageDisplay(
                        propertyId: property.id,
                        width: double.infinity,
                        height: screenHeight * 0.22,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            size: 16,
                            color: AppColors.darkWhiteText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            PropertyStatus.getLabel(property.propertyStatus),
                            style: const TextStyle(
                              color: AppColors.darkWhiteText,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildHeartButton(property.id),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.name.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹ ${property.price}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: priceColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildFormattedAddress(context, property.propertyAddress),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem(
                          Icons.hotel_outlined,
                          '${property.features.bedRooms} beds',
                        ),
                        _buildFeatureItem(
                          Icons.bathtub_outlined,
                          '${property.features.bathRooms} bath',
                        ),
                        _buildFeatureItem(
                          Icons.space_dashboard_outlined,
                          '${property.features.areaInSquarFoot} sf',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.greyColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.greyColor,
              ),
        ),
      ],
    );
  }

  Widget _buildHeartButton(String propertyId) {
    final isFavorited = true; // Always true since this is favorites page
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _removeFromFavorites(propertyId),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.7)
                : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.favorite,
            color: Colors.red,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedAddress(BuildContext context, Address address) {
    final List<String> addressParts = [];

    // Add street if not empty
    if (address.street.isNotEmpty) {
      addressParts.add(address.street);
    }

    // Add area if not empty
    if (address.area.isNotEmpty) {
      addressParts.add(address.area);
    }

    // Add city if not empty
    if (address.city.isNotEmpty) {
      addressParts.add(address.city);
    }

    // Add state if not empty
    if (address.state.isNotEmpty) {
      addressParts.add(address.state);
    }

    // Add zip/pin code if not empty
    if (address.zipOrPinCode.isNotEmpty) {
      addressParts.add(address.zipOrPinCode);
    }

    // Add country if not empty
    if (address.country.isNotEmpty) {
      addressParts.add(address.country);
    }

    // If no address parts, show a placeholder
    if (addressParts.isEmpty) {
      return Text(
        'Address not available',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.greyColor2,
              fontStyle: FontStyle.italic,
            ),
      );
    }

    // Join address parts with commas and spaces
    final formattedAddress = addressParts.join(', ');

    return Text(
      formattedAddress,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.greyColor2,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.greyColor2),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.greyColor2),
        ),
      ],
    );
  }
}
