import 'dart:io';

import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/services/file/userProfilePictureService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePictureController {
  final UserProfilePictureService _userProfilePictureService =
      UserProfilePictureService();

  String _formatImageUrl(String url) {
    if (url.isEmpty) return url;

    // Convert HTTP to HTTPS if needed
    if (url.startsWith('http://')) {
      url = 'https://${url.substring(7)}';
    }

    // Ensure the URL is properly formatted
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    return url;
  }

  Future<Map<String, dynamic>> upload(UsersModel currentUser, File file) async {
    Map<String, dynamic> response;
    var filePathSplit = file.path.split('/');
    var fileName = filePathSplit.isNotEmpty
        ? filePathSplit[filePathSplit.length - 1]
        : 'profilePicture_${DateTime.now().toString()}';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    response = await _userProfilePictureService.upload(
      token,
      currentUser.id,
      fileName,
      file,
    );

    if (response['statusCode'] == 200 && response['data'] != null) {
      // Try all possible fields for the image URL
      final data = response['data'];
      String? imageUrl =
          data['url'] ?? data['displayUrl'] ?? data['originalUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrl = _formatImageUrl(imageUrl);
        // Store the image URL in cache with user ID as key
        await prefs.setString('userProfilePicture_${currentUser.id}', imageUrl);
        response['data']['url'] = imageUrl;
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> get() async {
    UserController userController = UserController();
    final prefs = await SharedPreferences.getInstance();

    // Get current user
    UsersModel currentUser =
        await userController.getCurrentUserFromLocalStorage();
    var userId = currentUser.id;

    // Try to get from cache first
    final cachedUrl = prefs.getString('userProfilePicture_$userId') ?? "";
    if (cachedUrl.isNotEmpty) {
      final formattedUrl = _formatImageUrl(cachedUrl);
      if (formattedUrl != cachedUrl) {
        await prefs.setString('userProfilePicture_$userId', formattedUrl);
      }
      return {
        'statusCode': 200,
        'message': 'Success',
        'data': {'url': formattedUrl},
      };
    }

    // If not in cache, fetch from server
    final token = prefs.getString('token') ?? "";

    final response = await _userProfilePictureService.get(token, userId);

    if (response['statusCode'] == 200 && response['data'] != null) {
      final data = response['data'];
      String? imageUrl =
          data['url'] ?? data['displayUrl'] ?? data['originalUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrl = _formatImageUrl(imageUrl);
        // Cache the image URL
        await prefs.setString('userProfilePicture_$userId', imageUrl);
        response['data']['url'] = imageUrl;
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> getByUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";

    // Try to get from cache first
    final cachedUrl = prefs.getString('userProfilePicture_$userId') ?? "";
    if (cachedUrl.isNotEmpty) {
      final formattedUrl = _formatImageUrl(cachedUrl);
      return {
        'statusCode': 200,
        'message': 'Success',
        'data': {'url': formattedUrl},
      };
    }

    // If not in cache, fetch from server
    final response = await _userProfilePictureService.get(token, userId);
    if (response['statusCode'] == 200 && response['data'] != null) {
      final data = response['data'];
      String? imageUrl =
          data['url'] ?? data['displayUrl'] ?? data['originalUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrl = _formatImageUrl(imageUrl);
        // Cache the image URL
        await prefs.setString('userProfilePicture_$userId', imageUrl);
        response['data']['url'] = imageUrl;
      }
    }
    return response;
  }

  // Clear cache for a specific user
  Future<void> clearCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userProfilePicture_$userId');
  }

  // Clear all profile picture cache
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('userProfilePicture_')) {
        await prefs.remove(key);
      }
    }
  }
}
