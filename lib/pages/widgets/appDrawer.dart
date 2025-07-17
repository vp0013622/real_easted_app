import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/constants/drawerMenuList.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/pages/widgets/listTile.dart';
import 'package:inhabit_realties/pages/widgets/loader.dart';
import 'package:inhabit_realties/controllers/file/userProfilePictureController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = "";
  String userEmail = "";
  String? userProfileImage;
  bool isImageLoading = false;
  final UserProfilePictureController _profilePictureController =
      UserProfilePictureController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isImageLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUser = prefs.getString('currentUser') ?? "";
      if (currentUser.isNotEmpty) {
        final decodedCurrentUser = jsonDecode(currentUser);
        UsersModel usersModel = UsersModel.fromJson(decodedCurrentUser);

        // Get profile image using the controller
        try {
          final imageResponse = await _profilePictureController.get();
          String? imageUrl;

          if (imageResponse['statusCode'] == 200 &&
              imageResponse['data'] != null) {
            imageUrl = imageResponse['data']['url'];
          }

          setState(() {
            userName = "${usersModel.firstName} ${usersModel.lastName}";
            userEmail = usersModel.email;
            userProfileImage = imageUrl;
          });
        } catch (e) {
          // If profile image fails, still show user data
          setState(() {
            userName = "${usersModel.firstName} ${usersModel.lastName}";
            userEmail = usersModel.email;
            userProfileImage = null;
          });
        }
      }
    } catch (e) {
      // Error handled silently
    } finally {
      setState(() {
        isImageLoading = false;
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
    final brandColor =
        isDark ? AppColors.brandSecondary : AppColors.brandPrimary;

    return Drawer(
      backgroundColor: cardColor,
      child: Column(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(color: AppColors.lightBackground),
            child: Image.asset(
              'assets/images/applogo2.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          if (userName.isNotEmpty || userEmail.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isDark
                      ? [
                          AppColors.darkPrimary.withOpacity(0.1),
                          AppColors.brandSecondary.withOpacity(0.05),
                        ]
                      : [
                          AppColors.lightPrimary.withOpacity(0.1),
                          AppColors.brandPrimary.withOpacity(0.05),
                        ],
                ),
              ),
              child: Row(
                children: [
                  isImageLoading
                      ? const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: Loader()),
                        )
                      : CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          backgroundImage: userProfileImage != null
                              ? NetworkImage(
                                  userProfileImage!,
                                  headers: {
                                    'Cache-Control': 'no-cache',
                                    'Pragma': 'no-cache',
                                  },
                                )
                              : null,
                          onBackgroundImageError: (exception, stackTrace) {
                            // Handle image loading error silently
                          },
                          child: userProfileImage == null
                              ? Icon(
                                  CupertinoIcons.person_fill,
                                  size: 25,
                                  color: brandColor,
                                )
                              : null,
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (userName.isNotEmpty)
                          Text(
                            userName,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (userEmail.isNotEmpty)
                          Text(
                            userEmail,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: textColor.withOpacity(0.7)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: DrawerMenuList.list.length,
              itemBuilder: (context, index) {
                final item = DrawerMenuList.list[index];
                final isLogout = item['path'] == '/auth/logout';

                return Column(
                  children: [
                    DrawerListTile(
                      path: item['path'],
                      icon: item['icon'],
                      title: item['title'],
                    ),
                    if (isLogout || index == DrawerMenuList.list.length - 1)
                      const SizedBox(height: 8)
                    else if (index == 6) // Add divider after Meetings
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Divider(
                          color: textColor.withOpacity(0.1),
                          height: 1,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacity(0.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
