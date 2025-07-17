import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/file/userProfilePictureController.dart';

class ProfileAvatar extends StatefulWidget {
  final String userId;
  final String userName;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;

  const ProfileAvatar({
    Key? key,
    required this.userId,
    required this.userName,
    this.size = 60,
    this.backgroundColor,
    this.textColor,
    this.showBorder = true,
  }) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _profileImageUrl;
  bool _isLoadingImage = false;
  final UserProfilePictureController _profilePictureController =
      UserProfilePictureController();

  @override
  void initState() {
    super.initState();
    if (widget.userId.isNotEmpty) {
      _loadProfileImage();
    }
  }

  Future<void> _loadProfileImage() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final response =
          await _profilePictureController.getByUserId(widget.userId);

      if (response['statusCode'] == 200 && response['data'] != null) {
        final imageUrl = response['data']['url'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          setState(() {
            _profileImageUrl = imageUrl;
          });
        }
      }
    } catch (error) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = widget.backgroundColor ??
        (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground);
    final textColor = widget.textColor ??
        (isDark ? AppColors.darkWhiteText : AppColors.lightDarkText);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size / 2),
        color: backgroundColor,
        border: widget.showBorder
            ? Border.all(
                color: AppColors.brandPrimary.withOpacity(0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
            color: AppColors.brandPrimary.withOpacity(0.2),
          ),
        ],
      ),
      child: _isLoadingImage
          ? Center(
              child: SizedBox(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                child: CircularProgressIndicator(
                  color: AppColors.brandPrimary,
                  strokeWidth: 2,
                ),
              ),
            )
          : _profileImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular((widget.size - 4) / 2),
                  child: Image.network(
                    _profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialAvatar(textColor);
                    },
                  ),
                )
              : _buildInitialAvatar(textColor),
    );
  }

  Widget _buildInitialAvatar(Color textColor) {
    return Center(
      child: Text(
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
        style: TextStyle(
          color: textColor,
          fontSize: widget.size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
