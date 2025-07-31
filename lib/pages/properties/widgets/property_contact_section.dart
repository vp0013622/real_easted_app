import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/controllers/file/userProfilePictureController.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/pages/widgets/appSpinner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class PropertyContactSection extends StatefulWidget {
  final PropertyModel property;

  const PropertyContactSection({Key? key, required this.property})
      : super(key: key);

  @override
  State<PropertyContactSection> createState() => _PropertyContactSectionState();
}

class _PropertyContactSectionState extends State<PropertyContactSection> {
  final UserController _userController = UserController();
  final UserProfilePictureController _profilePictureController =
      UserProfilePictureController();
  UsersModel? ownerDetails;
  bool isLoading = true;
  bool isImageLoading = false;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadOwnerDetails();
  }

  Future<void> _loadOwnerDetails() async {
    setState(() {
      isLoading = true;
      isImageLoading = true;
    });

    try {
      // Get owner details
      final response = await _userController.getUsersByUserId(
        widget.property.owner,
      );

      if (response['statusCode'] == 200 && mounted) {
        // Get owner's profile picture
        try {
          final pictureResponse = await _profilePictureController
              .getByUserId(widget.property.owner);
          String? imageUrl;

          if (pictureResponse['statusCode'] == 200 &&
              pictureResponse['data'] != null) {
            imageUrl = pictureResponse['data']['url'];
          }

          if (mounted) {
            setState(() {
              ownerDetails = UsersModel.fromJson(response['data']);
              profileImageUrl = imageUrl;
              isLoading = false;
              isImageLoading = false;
            });
          }
        } catch (pictureError) {
          // Continue without profile picture
          if (mounted) {
            setState(() {
              ownerDetails = UsersModel.fromJson(response['data']);
              profileImageUrl = null;
              isLoading = false;
              isImageLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            isImageLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isImageLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final brandColor =
        isDark ? AppColors.brandSecondary : AppColors.brandPrimary;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: AppSpinner())
          else if (ownerDetails != null)
            Column(
              children: [
                // Owner info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: brandColor.withOpacity(0.1),
                      backgroundImage: (profileImageUrl != null &&
                              profileImageUrl!.isNotEmpty)
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child:
                          (profileImageUrl == null || profileImageUrl!.isEmpty)
                              ? Text(
                                  ownerDetails!.firstName.isNotEmpty &&
                                          ownerDetails!.lastName.isNotEmpty
                                      ? '${ownerDetails!.firstName[0]}${ownerDetails!.lastName[0]}'
                                      : '?',
                                  style: TextStyle(
                                    color: brandColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ownerDetails!.firstName} ${ownerDetails!.lastName}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ownerDetails!.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.greyColor2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Contact buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final phone = ownerDetails?.phoneNumber ?? '';
                          if (phone.isNotEmpty) {
                            final uri = Uri.parse('tel:$phone');
                            if (await canLaunchUrl(uri)) {
                              final launched = await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                              if (!launched && context.mounted) {
                                AppSnackBar.showSnackBar(
                                  context,
                                  'Error',
                                  'Could not launch dialer',
                                  ContentType.failure,
                                );
                              }
                            } else {
                              if (context.mounted) {
                                AppSnackBar.showSnackBar(
                                  context,
                                  'Error',
                                  'Could not launch dialer',
                                  ContentType.failure,
                                );
                              }
                            }
                          } else {
                            if (context.mounted) {
                              AppSnackBar.showSnackBar(
                                context,
                                'Warning',
                                'Phone number not available',
                                ContentType.warning,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightSuccess,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final phone = ownerDetails?.phoneNumber ?? '';
                          if (phone.isNotEmpty) {
                            // Try multiple SMS schemes for better Android compatibility
                            final smsUri = Uri.parse('sms:$phone');
                            final smsToUri = Uri.parse('sms:$phone?body=');

                            bool launched = false;

                            // Try the first format
                            if (await canLaunchUrl(smsUri)) {
                              launched = await launchUrl(smsUri,
                                  mode: LaunchMode.externalApplication);
                            }

                            // If first format fails, try the second format
                            if (!launched && await canLaunchUrl(smsToUri)) {
                              launched = await launchUrl(smsToUri,
                                  mode: LaunchMode.externalApplication);
                            }

                            if (!launched) {
                              if (context.mounted) {
                                AppSnackBar.showSnackBar(
                                  context,
                                  'Error',
                                  'Could not launch messaging app',
                                  ContentType.failure,
                                );
                              }
                            }
                          } else {
                            if (context.mounted) {
                              AppSnackBar.showSnackBar(
                                context,
                                'Warning',
                                'Phone number not available',
                                ContentType.warning,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Center(
              child: Text(
                'Owner information not available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyColor2,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
