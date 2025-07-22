import 'package:flutter/material.dart';
import 'package:inhabit_realties/controllers/property/propertyController.dart';
import 'package:inhabit_realties/controllers/propertyType/propertyTypeController.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/models/propertyType/PropertyTypeModel.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import 'package:inhabit_realties/pages/widgets/app_search_bar.dart';
import 'package:inhabit_realties/pages/properties/widgets/propertyTypeContainer.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/Enums/propertyStatusEnum.dart';
import 'package:flutter/cupertino.dart';

class SelectPropertyPage extends StatefulWidget {
  final List<String> selectedCustomerIds;
  final Function(String) onPropertySelected;

  const SelectPropertyPage({
    super.key,
    required this.selectedCustomerIds,
    required this.onPropertySelected,
  });

  @override
  State<SelectPropertyPage> createState() => _SelectPropertyPageState();
}

class _SelectPropertyPageState extends State<SelectPropertyPage> {
  final PropertyController _propertyController = PropertyController();
  final PropertyTypeController _propertyTypeController =
      PropertyTypeController();

  List<PropertyModel> _properties = [];
  List<PropertyModel> _filteredProperties = [];
  List<PropertyTypeModel> _propertyTypes = [];
  String? _selectedPropertyId;
  String? _selectedPropertyTypeId;
  String? _selectedPropertyStatus;
  bool _isDataLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isDataLoading = true;
      });

      await Future.wait([
        _loadProperties(),
        _loadPropertyTypes(),
      ]);

      if (mounted) {
        setState(() {
          _isDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDataLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadProperties() async {
    try {
      final response = await _propertyController.getAllProperties();
      if (response['statusCode'] == 200 && mounted) {
        setState(() {
          _properties = (response['data'] as List)
              .map((item) => PropertyModel.fromJson(item))
              .toList();
          _filteredProperties = List.from(_properties);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading properties: $e')),
        );
      }
    }
  }

  Future<void> _loadPropertyTypes() async {
    try {
      final response = await _propertyTypeController.getAllPropertyTypes();
      if (response['statusCode'] == 200 && mounted) {
        setState(() {
          _propertyTypes = (response['data'] as List)
              .map((item) => PropertyTypeModel.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _handleSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProperties = List.from(_properties);
      } else {
        _filteredProperties = _properties.where((property) {
          final name = property.name.toString().toLowerCase();
          final address = _getFormattedAddressString(property.propertyAddress)
              .toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || address.contains(searchLower);
        }).toList();
      }
    });
  }

  void _applyFilters() {
    setState(() {
      List<PropertyModel> filtered = List.from(_properties);

      // Apply property type filter
      if (_selectedPropertyTypeId != null && _selectedPropertyTypeId != 'all') {
        filtered = filtered
            .where((property) =>
                property.propertyTypeId == _selectedPropertyTypeId)
            .toList();
      }

      // Apply property status filter
      if (_selectedPropertyStatus != null) {
        filtered = filtered
            .where((property) =>
                property.propertyStatus == _selectedPropertyStatus)
            .toList();
      }

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        filtered = filtered.where((property) {
          final name = property.name.toString().toLowerCase();
          final address = _getFormattedAddressString(property.propertyAddress)
              .toLowerCase();
          final searchLower = _searchController.text.toLowerCase();
          return name.contains(searchLower) || address.contains(searchLower);
        }).toList();
      }

      _filteredProperties = filtered;
    });
  }

  String _getFormattedAddressString(Address address) {
    final List<String> addressParts = [];

    if (address.street.isNotEmpty) addressParts.add(address.street);
    if (address.area.isNotEmpty) addressParts.add(address.area);
    if (address.city.isNotEmpty) addressParts.add(address.city);
    if (address.state.isNotEmpty) addressParts.add(address.state);
    if (address.zipOrPinCode.isNotEmpty) addressParts.add(address.zipOrPinCode);
    if (address.country.isNotEmpty) addressParts.add(address.country);

    return addressParts.join(', ');
  }

  void _selectProperty(String propertyId) {
    setState(() {
      _selectedPropertyId = propertyId;
    });
  }

  void _proceedToMeetingDetails() {
    if (_selectedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a property')),
      );
      return;
    }

    widget.onPropertySelected(_selectedPropertyId!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Property'),
        actions: [
          TextButton(
            onPressed:
                _selectedPropertyId != null ? _proceedToMeetingDetails : null,
            child: Text(
              'Proceed',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: backgroundColor,
              child: Column(
                children: [
                  // Selected customers info
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.brandPrimary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: AppColors.brandPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.selectedCustomerIds.length} customer${widget.selectedCustomerIds.length == 1 ? '' : 's'} selected',
                            style: TextStyle(
                              color: AppColors.brandPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: AppSearchBar(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      hintText: 'Search properties...',
                      onClear: () => _handleSearch(''),
                    ),
                  ),

                  // Property Type Filter
                  if (_propertyTypes.isNotEmpty)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                            _propertyTypes.length + 1, // +1 for "All" option
                        itemBuilder: (context, index) {
                          final isAllOption = index == 0;
                          final propertyType = isAllOption
                              ? PropertyTypeModel(
                                  id: 'all',
                                  typeName: 'ALL',
                                  description: 'All types',
                                  createdByUserId: '0',
                                  updatedByUserId: '0',
                                  published: true,
                                )
                              : _propertyTypes[index - 1];
                          final isSelected =
                              _selectedPropertyTypeId == propertyType.id;

                          return Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 20 : 8,
                              right: index == _propertyTypes.length ? 20 : 8,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPropertyTypeId = propertyType.id;
                                });
                                _applyFilters();
                              },
                              child: PropertyTypeContainer(
                                isActive: isSelected,
                                propertyType: propertyType.typeName,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Property Status Filter
                  Container(
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: PropertyStatus.values.length +
                          1, // +1 for "All" option
                      itemBuilder: (context, index) {
                        final isAllOption = index == 0;
                        final status = isAllOption
                            ? 'ALL'
                            : PropertyStatus.values[index - 1];
                        final isSelected = isAllOption
                            ? _selectedPropertyStatus == null
                            : _selectedPropertyStatus == status;

                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 20 : 8,
                            right:
                                index == PropertyStatus.values.length ? 20 : 8,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPropertyStatus =
                                    isAllOption ? null : status;
                              });
                              _applyFilters();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.brandSecondary
                                        : AppColors.brandPrimary)
                                    : (isDark
                                        ? AppColors.darkCardBackground
                                        : AppColors.lightCardBackground),
                              ),
                              child: Text(
                                status,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: isSelected
                                          ? AppColors.darkWhiteText
                                          : (isDark
                                              ? AppColors.darkWhiteText
                                              : AppColors.lightDarkText),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Properties List
                  Expanded(
                    child: _filteredProperties.isEmpty
                        ? Center(
                            child: Text(
                              'No properties available',
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _filteredProperties.length,
                            itemBuilder: (context, index) {
                              final property = _filteredProperties[index];
                              final isSelected =
                                  _selectedPropertyId == property.id;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: isSelected ? 4 : 1,
                                color: isSelected
                                    ? AppColors.brandPrimary.withOpacity(0.1)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isSelected
                                      ? BorderSide(
                                          color: AppColors.brandPrimary,
                                          width: 2)
                                      : BorderSide.none,
                                ),
                                child: InkWell(
                                  onTap: () => _selectProperty(property.id),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Radio button
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? AppColors.brandPrimary
                                                : AppColors.greyColor2,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                )
                                              : null,
                                        ),

                                        const SizedBox(width: 16),

                                        // Property Icon
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: AppColors.brandPrimary
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.home,
                                            color: AppColors.brandPrimary,
                                            size: 24,
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // Property Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                property.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${property.propertyAddress.city}, ${property.propertyAddress.state}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.greyColor2,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .lightSuccess
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      '₹${property.price.toStringAsFixed(0)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .lightSuccess,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .brandPrimary
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      property.propertyStatus,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .brandPrimary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
