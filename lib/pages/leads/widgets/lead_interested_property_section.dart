import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/lead/LeadsModel.dart';
import 'package:inhabit_realties/services/property/propertyService.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/pages/properties/property_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeadInterestedPropertySection extends StatefulWidget {
  final LeadsModel lead;

  const LeadInterestedPropertySection({Key? key, required this.lead})
      : super(key: key);

  @override
  State<LeadInterestedPropertySection> createState() =>
      _LeadInterestedPropertySectionState();
}

class _LeadInterestedPropertySectionState
    extends State<LeadInterestedPropertySection> {
  final PropertyService _propertyService = PropertyService();
  PropertyModel? _interestedProperty;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInterestedPropertyDetails();
  }

  Future<void> _loadInterestedPropertyDetails() async {
    if (widget.lead.leadInterestedPropertyId.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final propertyResult = await _propertyService.getPropertyById(
        token,
        widget.lead.leadInterestedPropertyId,
      );

      if (propertyResult['statusCode'] == 200 &&
          propertyResult['data'] != null) {
        setState(() {
          _interestedProperty = PropertyModel.fromJson(propertyResult['data']);
        });
      }
    } catch (error) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final secondaryTextColor =
        isDark ? AppColors.greyColor : AppColors.greyColor2;

    // Check if there's interested property information to show
    final hasInterestedProperty =
        widget.lead.leadInterestedPropertyId.isNotEmpty;

    if (!hasInterestedProperty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      color: AppColors.brandPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Interested Property',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                    ),
                  ],
                ),
                if (_interestedProperty != null)
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailsPage(
                              property: _interestedProperty!),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.visibility,
                      color: isDark
                          ? AppColors.brandSecondary
                          : AppColors.brandPrimary,
                      size: 20,
                    ),
                    tooltip: 'View Property',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 48,
                    color: secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No interested property specified',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Interested Property',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                  ),
                ],
              ),
              if (_interestedProperty != null)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PropertyDetailsPage(property: _interestedProperty!),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.visibility,
                    color: isDark
                        ? AppColors.brandSecondary
                        : AppColors.brandPrimary,
                    size: 20,
                  ),
                  tooltip: 'View Property',
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.brandPrimary,
                ),
              ),
            )
          else if (_interestedProperty != null)
            _buildPropertyInfo(context, secondaryTextColor)
          else
            _buildPropertyIdFallback(secondaryTextColor),
        ],
      ),
    );
  }

  Widget _buildPropertyInfo(BuildContext context, Color secondaryTextColor) {
    final property = _interestedProperty!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.home_outlined,
              size: 16,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Property Name',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyIdFallback(Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.home_outlined,
              size: 16,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Property ID',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.lead.leadInterestedPropertyId,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 24,
                color: secondaryTextColor.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to load property details',
                style: TextStyle(
                  color: secondaryTextColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Please check your connection and try again',
                style: TextStyle(
                  color: secondaryTextColor.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
