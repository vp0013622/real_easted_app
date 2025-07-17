import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import 'package:inhabit_realties/pages/properties/widgets/property_image_display.dart';

class PropertyDetailHeader extends StatelessWidget {
  final PropertyModel property;
  final bool isExpanded;

  const PropertyDetailHeader({
    Key? key,
    required this.property,
    required this.isExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isExpanded ? 0.0 : 1.0,
          child: Text(
            property.name,
            style: const TextStyle(
              color: AppColors.darkWhiteText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Property Image
            Hero(
              tag: 'property_${property.id}',
              child: PropertyImageDisplay(
                propertyId: property.id,
                width: double.infinity,
                height: 300.0,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            // Property name when expanded
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isExpanded ? 1.0 : 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(
                        color: AppColors.darkWhiteText,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.darkWhiteText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _getFormattedAddress(property.propertyAddress),
                            style: const TextStyle(
                              color: AppColors.darkWhiteText,
                              fontSize: 14.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedAddress(Address address) {
    final List<String> addressParts = [];
    
    if (address.area.isNotEmpty) addressParts.add(address.area);
    if (address.city.isNotEmpty) addressParts.add(address.city);
    if (address.state.isNotEmpty) addressParts.add(address.state);
    if (address.zipOrPinCode.isNotEmpty) addressParts.add(address.zipOrPinCode);
    
    return addressParts.join(', ');
  }
}
