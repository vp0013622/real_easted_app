import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/models/favoriteProperty/FavoritePropertyModel.dart';
import 'package:inhabit_realties/services/favoriteProperty/favoritePropertyService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class FavoritePropertyController extends ChangeNotifier {
  List<FavoritePropertyModel> _favoriteProperties = [];
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _favoriteStatus = {}; // Cache for favorite status

  // Getters
  List<FavoritePropertyModel> get favoriteProperties => _favoriteProperties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if a property is favorited
  bool isPropertyFavorited(String propertyId) {
    return _favoriteStatus[propertyId] ?? false;
  }

  // Get current user ID from SharedPreferences
  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('currentUser');
    if (currentUser != null && currentUser.isNotEmpty) {
      try {
        final userData = jsonDecode(currentUser);
        return userData['_id'];
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Debug authentication status
  Future<void> _debugAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final currentUser = prefs.getString('currentUser');



      if (token != null && token.isNotEmpty) {}

      if (currentUser != null && currentUser.isNotEmpty) {
        try {
          final userData = jsonDecode(currentUser);
        } catch (e) {}
      }
    } catch (e) {}
  }

  // Load favorite properties from backend
  Future<void> loadFavoriteProperties() async {
    try {
      _setLoading(true);
        _error = null;

      final userId = await _getCurrentUserId();

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response =
          await FavoritePropertyService.getFavoriteProperties(userId);

      if (response['statusCode'] == 200) {
        final List<dynamic> data = response['data'] ?? [];
        _favoriteProperties =
            data.map((item) => FavoritePropertyModel.fromJson(item)).toList();

        // Clear the cache first to ensure we start fresh
        _favoriteStatus.clear();

        // Update favorite status cache - only mark properties that are actually favorited
        for (var favorite in _favoriteProperties) {
          _favoriteStatus[favorite.propertyId] = true;
        }

        // Note: Properties not in the favorites list will remain as false (default)
        // This ensures that unfavorited properties are correctly marked as false
      } else {
        _error = response['message'] ?? 'Failed to load favorite properties';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add property to favorites
  Future<bool> addToFavorites(String propertyId, BuildContext context) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        _showErrorSnackBar(context, 'Please log in to add favorites');
        throw Exception('User ID not found');
      }

      final response =
          await FavoritePropertyService.addToFavorites(userId, propertyId);

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        // Update cache
        _favoriteStatus[propertyId] = true;
        notifyListeners();
        _showSuccessSnackBar(context, 'Property added to favorites!');
        return true;
      } else if (response['statusCode'] == 409) {
        // Property already in favorites
        _favoriteStatus[propertyId] = true;
        notifyListeners();
        _showWarningSnackBar(context, 'Property is already in your favorites');
        return true;
      } else {
        _showErrorSnackBar(
            context, 'Failed to add to favorites: ${response['message']}');
        return false;
      }
    } catch (e) {
      _showErrorSnackBar(
          context, 'Error adding to favorites. Please try again.');
      return false;
    }
  }

  // Remove property from favorites
  Future<bool> removeFromFavorites(
      String propertyId, BuildContext context) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        _showErrorSnackBar(context, 'Please log in to manage favorites');
        throw Exception('User ID not found');
      }

      final response =
          await FavoritePropertyService.removeFromFavorites(userId, propertyId);

      if (response['statusCode'] == 200 || response['statusCode'] == 204) {
        // Update cache
        _favoriteStatus[propertyId] = false;
        notifyListeners();
        _showSuccessSnackBar(context, 'Property removed from favorites');
        return true;
      } else if (response['statusCode'] == 404) {
        // Property not in favorites
        _favoriteStatus[propertyId] = false;
        notifyListeners();
        _showWarningSnackBar(context, 'Property was not in your favorites');
        return true;
      } else {
        _showErrorSnackBar(
            context, 'Failed to remove from favorites: ${response['message']}');
        return false;
      }
    } catch (e) {
      _showErrorSnackBar(
          context, 'Error removing from favorites. Please try again.');
      return false;
    }
  }

  // Clear invalid authentication data
  Future<void> _clearInvalidAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('currentUser');
    } catch (e) {}
  }

  // Check if user is properly authenticated
  Future<bool> _isUserAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final currentUser = prefs.getString('currentUser');

      if (token == null || token.isEmpty) {
        return false;
      }

      if (currentUser == null || currentUser.isEmpty) {
        return false;
      }

      // Basic token format validation
      if (!token.contains('.') || token.split('.').length != 3) {
        await _clearInvalidAuthData();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String propertyId, BuildContext context) async {
    // Debug authentication status first
    await _debugAuthStatus();

    if (isPropertyFavorited(propertyId)) {
      return await removeFromFavorites(propertyId, context);
    } else {

      return await addToFavorites(propertyId, context);
    }
  }

  // Check favorite status for a property
  Future<void> checkFavoriteStatus(String propertyId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        _favoriteStatus[propertyId] = false;
        return;
      }

      final response =
          await FavoritePropertyService.checkIfFavorited(userId, propertyId);

      if (response['statusCode'] == 200) {
        _favoriteStatus[propertyId] = response['isFavorited'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      _favoriteStatus[propertyId] = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Update state with callback
  void updateState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // Show snackbar message
  void _showSnackBar(BuildContext context, String title, String message,
      ContentType contentType) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    _showSnackBar(context, 'Success!', message, ContentType.success);
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(context, 'Error!', message, ContentType.failure);
  }

  // Show warning snackbar
  void _showWarningSnackBar(BuildContext context, String message) {
    _showSnackBar(context, 'Warning!', message, ContentType.warning);
  }

  // Show help snackbar
  void _showHelpSnackBar(BuildContext context, String message) {
    _showSnackBar(context, 'Info!', message, ContentType.help);
  }
}
