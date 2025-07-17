import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/Enums/propertyStatusEnum.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_detail_header.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_features_section.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_location_section.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_amenities_section.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_contact_section.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_images_section.dart';
import 'package:inhabit_realties/pages/properties/editProperty_page.dart';

class PropertyDetailsPage extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailsPage({Key? key, required this.property})
      : super(key: key);

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAppBarExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _isAppBarExpanded = _scrollController.hasClients &&
              _scrollController.offset > (200 - kToolbarHeight);
        });
      });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              PropertyDetailHeader(
                property: widget.property,
                isExpanded: !_isAppBarExpanded,
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price and Status Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '₹${widget.property.price}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.darkSuccess
                                                : AppColors.lightSuccess,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Listed on ${widget.property.listedDate.toString().split(' ')[0]}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.greyColor,
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.brandSecondary
                                        : AppColors.brandPrimary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    PropertyStatus.getLabel(
                                        widget.property.propertyStatus),
                                    style: const TextStyle(
                                      color: AppColors.darkWhiteText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.property.description,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.greyColor2,
                                        height: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Property Images Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: PropertyImagesSection(
                              propertyId: widget.property.id,
                              isEditable: true, // Allow editing for now
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Features Section
                          PropertyFeaturesSection(
                            features: widget.property.features,
                          ),
                          const SizedBox(height: 16),

                          // Location Section
                          PropertyLocationSection(
                            address: widget.property.propertyAddress,
                            propertyName: widget.property.name,
                          ),
                          const SizedBox(height: 16),

                          // Amenities Section
                          PropertyAmenitiesSection(
                            features: widget.property.features,
                          ),
                          const SizedBox(height: 16),

                          // Contact Section
                          PropertyContactSection(property: widget.property),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.back,
                    color: isDark
                        ? AppColors.darkWhiteText
                        : AppColors.lightDarkText,
                  ),
                ),
              ),
            ),
          ),
          // Edit Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditPropertyPage(),
                      settings: RouteSettings(arguments: widget.property),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.pencil,
                    color: AppColors.darkWhiteText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
