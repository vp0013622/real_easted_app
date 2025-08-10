// ignore_for_file: prefer_final_fields

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/address/userAddressController.dart';
import 'package:inhabit_realties/models/address/UserAddressModel.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/pages/widgets/appSnackBar.dart';
import 'package:inhabit_realties/pages/widgets/formTextField.dart';
import 'package:inhabit_realties/controllers/selectors/countryStateSelector.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:dropdown_button2/dropdown_button2.dart';

class AddUserAddressPage extends StatefulWidget {
  final UsersModel user;

  const AddUserAddressPage({super.key, required this.user});

  @override
  State<AddUserAddressPage> createState() => _AddUserAddressPageState();
}

class _AddUserAddressPageState extends State<AddUserAddressPage> {
  // Add these constants at the class level for consistent styling
  static const double _formPadding = 10.0;
  static const double _formTopPadding = 10.0;
  static const double _formBottomPadding = 10.0;
  static const EdgeInsets _fieldPadding = EdgeInsets.only(
    top: 20,
    left: 15,
    right: 15,
  );
  static const EdgeInsets _dropdownContentPadding = EdgeInsets.symmetric(
    horizontal: 15,
    vertical: 15,
  );
  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(10.0),
  );

  // Add these constants for consistent styling
  static const double _sectionSpacing = 25.0;
  static const double _headerSpacing = 15.0;
  static const EdgeInsets _sectionPadding = EdgeInsets.only(
    bottom: _sectionSpacing,
  );

  final UserAddressController _userAddressController = UserAddressController();
  final CountryStateSelector _countryStateSelector = CountryStateSelector();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _street = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _zipOrPinCode = TextEditingController();
  final TextEditingController _country = TextEditingController();

  // Search controllers for dropdowns
  final TextEditingController _countrySearchController = TextEditingController();
  final TextEditingController _stateSearchController = TextEditingController();
  final TextEditingController _citySearchController = TextEditingController();

  // Country, State, City data
  List<csc.Country> countries = [];
  List<csc.State> states = [];
  List<csc.City> cities = [];

  // Selected values
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  bool isLoading = false;
  bool isDataLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isDataLoading = true;
    });
    await getAllCSC();
    setState(() {
      isDataLoading = false;
    });
  }

  Future<void> getAllCSC() async {
    try {
      final loadedCountries = await _countryStateSelector.getCountries();
      if (mounted) {
        setState(() {
          countries = loadedCountries;
        });
      }
    } catch (e) {
      // Handle error appropriately
    }
  }

  @override
  void dispose() {
    _street.dispose();
    _area.dispose();
    _city.dispose();
    _state.dispose();
    _zipOrPinCode.dispose();
    _country.dispose();
    _countrySearchController.dispose();
    _stateSearchController.dispose();
    _citySearchController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final address = Address(
        street: _street.text.trim(),
        area: _area.text.trim(),
        city: selectedCity ?? _city.text.trim(),
        state: selectedState ?? _state.text.trim(),
        zipOrPinCode: _zipOrPinCode.text.trim(),
        country: selectedCountry ?? _country.text.trim(),
        location: Location(lat: 0.0, lng: 0.0), // Default location, can be enhanced later
      );

      final userAddress = UserAddressModel(
        id: '',
        userId: widget.user.id,
        address: address,
        createdByUserId: widget.user.id,
        updatedByUserId: widget.user.id,
        published: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _userAddressController.createUserAddress(userAddress);

      if (mounted) {
        if (response['statusCode'] == 200 || response['statusCode'] == 201) {
          AppSnackBar.showSnackBar(
            context,
            'Success',
            'Address added successfully',
            ContentType.success,
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          AppSnackBar.showSnackBar(
            context,
            'Error',
            response['message'] ?? 'Failed to add address',
            ContentType.failure,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showSnackBar(
          context,
          'Error',
          'An error occurred while adding address',
          ContentType.failure,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildDropdownField({
    required String labelText,
    required IconData prefixIcon,
    required Widget child,
  }) {
    return Padding(
      padding: _fieldPadding,
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: _dropdownContentPadding,
            border: OutlineInputBorder(borderRadius: _borderRadius),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: _sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: _headerSpacing),
          FormTextField(
            textEditingController: _street,
            labelText: 'Street Address (Optional)',
            prefixIcon: CupertinoIcons.location,
            validator: (value) {
              // Street is optional
              return null;
            },
          ),
          FormTextField(
            textEditingController: _area,
            labelText: 'Area/Locality',
            prefixIcon: CupertinoIcons.map,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Area is required';
              }
              return null;
            },
          ),
          _buildDropdownField(
            labelText: 'Country',
            prefixIcon: CupertinoIcons.globe,
            child: DropdownButtonFormField2<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(CupertinoIcons.globe),
              ),
              value: selectedCountry,
              onChanged: (String? value) async {
                if (value != null) {
                  final country = countries.firstWhere((c) => c.name == value);
                  states = await _countryStateSelector.getStatesByCountryCode(country);
                  cities = await _countryStateSelector.getCitiesByCountryCode(country);
                  if (mounted) {
                    setState(() {
                      selectedCountry = value;
                      _country.text = value;
                      selectedState = null;
                      selectedCity = null;
                    });
                  }
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Country is required';
                }
                return null;
              },
              items: countries.map((csc.Country country) {
                return DropdownMenuItem<String>(
                  value: country.name,
                  child: Text(country.name),
                );
              }).toList(),
              dropdownSearchData: DropdownSearchData(
                searchController: _countrySearchController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _countrySearchController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: _dropdownContentPadding,
                      hintText: 'Search country...',
                      border: OutlineInputBorder(borderRadius: _borderRadius),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return item.value!.toLowerCase().contains(
                        searchValue.toLowerCase(),
                      );
                },
              ),
              dropdownStyleData: const DropdownStyleData(
                maxHeight: 300,
                decoration: BoxDecoration(borderRadius: _borderRadius),
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          _buildDropdownField(
            labelText: 'State/Province',
            prefixIcon: CupertinoIcons.map_pin,
            child: DropdownButtonFormField2<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'State/Province',
                prefixIcon: Icon(CupertinoIcons.map_pin),
              ),
              value: selectedState,
              items: states.map((csc.State state) {
                return DropdownMenuItem<String>(
                  value: state.name,
                  child: Text(state.name),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedState = value;
                    _state.text = value;
                    selectedCity = null;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'State is required';
                }
                return null;
              },
              dropdownSearchData: DropdownSearchData(
                searchController: _stateSearchController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _stateSearchController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: _dropdownContentPadding,
                      hintText: 'Search state...',
                      border: OutlineInputBorder(borderRadius: _borderRadius),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return item.value!.toLowerCase().contains(
                        searchValue.toLowerCase(),
                      );
                },
              ),
              dropdownStyleData: const DropdownStyleData(
                maxHeight: 300,
                decoration: BoxDecoration(borderRadius: _borderRadius),
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          _buildDropdownField(
            labelText: 'City',
            prefixIcon: CupertinoIcons.building_2_fill,
            child: DropdownButtonFormField2<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(CupertinoIcons.building_2_fill),
              ),
              value: selectedCity,
              items: cities.map((csc.City city) {
                return DropdownMenuItem<String>(
                  value: city.name,
                  child: Text(city.name),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value;
                    _city.text = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'City is required';
                }
                return null;
              },
              dropdownSearchData: DropdownSearchData(
                searchController: _citySearchController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _citySearchController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: _dropdownContentPadding,
                      hintText: 'Search city...',
                      border: OutlineInputBorder(borderRadius: _borderRadius),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return item.value!.toLowerCase().contains(
                        searchValue.toLowerCase(),
                      );
                },
              ),
              dropdownStyleData: const DropdownStyleData(
                maxHeight: 300,
                decoration: BoxDecoration(borderRadius: _borderRadius),
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          FormTextField(
            textEditingController: _zipOrPinCode,
            labelText: 'ZIP/PIN Code',
            prefixIcon: CupertinoIcons.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'ZIP/PIN Code is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.darkWhiteText,
                  ),
                ),
              )
            : const Text(
                'Add Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBackgroundColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Address',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          if (!isLoading)
            TextButton(
              onPressed: _handleSubmit,
              child: Text(
                'Save',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAddressSection(),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
} 