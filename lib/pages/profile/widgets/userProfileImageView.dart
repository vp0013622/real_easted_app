// ignore_for_file: use_build_context_synchronously, prefer_final_fields, avoid_init_to_null

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/file/userProfilePictureController.dart';
import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/pages/widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:inhabit_realties/pages/widgets/loader.dart';

class UserProfileImageView extends StatefulWidget {
  const UserProfileImageView({super.key});

  @override
  State<UserProfileImageView> createState() => _UserProfileImageViewState();
}

class _UserProfileImageViewState extends State<UserProfileImageView> {
  String? _imageUrl;
  bool isPageLoading = false;
  bool isProfileImageLoading = false;
  UserController _userController = UserController();
  UserProfilePictureController _userProfilePictureController =
      UserProfilePictureController();
  var _currentUser = null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isPageLoading = true;
    });
    await getCurrentUserFromLocalStorage();
    await getUserProfileImage();
    setState(() {
      isPageLoading = false;
    });
  }

  Future<void> getCurrentUserFromLocalStorage() async {
    final currentUser = await _userController.getCurrentUserFromLocalStorage();
    setState(() {
      _currentUser = currentUser;
    });
  }

  Future<void> getUserProfileImage() async {
    setState(() {
      isProfileImageLoading = true;
    });

    try {
      Map<String, dynamic> response = await _userProfilePictureController.get();
      if (response['statusCode'] == 200) {
        setState(() {
          var url = response['data']['url'];
          if (url != null && url is String && url.isNotEmpty) {
            _imageUrl = url;
          } else {
            _imageUrl = null;
          }
        });
      }
    } catch (e) {
      // Error handled silently
    } finally {
      setState(() {
        isProfileImageLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      isProfileImageLoading = true;
    });

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        var file = File(pickedFile.path);
        var response = await _userProfilePictureController.upload(
          _currentUser,
          file,
        );

        if (response['statusCode'] == 200) {
          // Clear the current image first
          setState(() {
            _imageUrl = null;
          });

          // Wait a moment then set the new image
          await Future.delayed(const Duration(milliseconds: 300));

          setState(() {
            var url = response['data']['url'];
            if (url != null && url is String && url.isNotEmpty) {
              _imageUrl = url;
            } else {
              _imageUrl = null;
            }
          });

          // Force refresh the image by calling getUserProfileImage
          await Future.delayed(const Duration(milliseconds: 500));
          await getUserProfileImage();

          AppSnackBar.showSnackBar(
            context,
            'Success',
            response['message'],
            ContentType.success,
          );
        } else {
          AppSnackBar.showSnackBar(
            context,
            'Failed',
            response['message'],
            ContentType.failure,
          );
        }
      }
    } catch (e) {
      AppSnackBar.showSnackBar(
        context,
        'Error',
        'Failed to update profile picture',
        ContentType.failure,
      );
    } finally {
      setState(() {
        isProfileImageLoading = false;
      });
    }
  }

  // Method to clear cache and refresh (useful for testing)
  Future<void> _refreshProfileImage() async {
    if (_currentUser != null) {
      await _userProfilePictureController.clearCache(_currentUser.id);
      await getUserProfileImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final dangerColor = isDark ? AppColors.darkDanger : AppColors.lightDanger;

    if (isPageLoading) {
      return const SizedBox(width: 120, height: 120, child: Loader());
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: isProfileImageLoading
              ? const SizedBox(width: 120, height: 120, child: Loader())
              : (_imageUrl != null && _imageUrl!.isNotEmpty)
                  ? Image.network(
                      _imageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: dangerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            CupertinoIcons.person_circle_fill,
                            color: dangerColor,
                            size: 80,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Center(child: Loader()),
                        );
                      },
                      headers: const {
                        'Cache-Control': 'no-cache',
                        'Pragma': 'no-cache',
                      },
                      cacheWidth: 240,
                      cacheHeight: 240,
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        CupertinoIcons.person_circle_fill,
                        color: textColor.withOpacity(0.5),
                        size: 80,
                      ),
                    ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isProfileImageLoading ? null : _pickImageFromGallery,
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: textColor, width: 2),
              ),
              child: Icon(
                isProfileImageLoading
                    ? CupertinoIcons.hourglass
                    : CupertinoIcons.pencil,
                color: textColor,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
