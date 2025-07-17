// ignore_for_file: file_names

import 'dart:io';
abstract class UserProfilePictureInterface {
  Future<Map<String, dynamic>> upload(String token, String userId, String fileName, File file);
  Future<Map<String, dynamic>> get(String token, String userID);
}