import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/property/PropertyImageModel.dart';
import 'package:inhabit_realties/services/property/propertyImageService.dart';

class PropertyImageDisplay extends StatefulWidget {
  final String propertyId;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PropertyImageDisplay({
    super.key,
    required this.propertyId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<PropertyImageDisplay> createState() => _PropertyImageDisplayState();
}

class _PropertyImageDisplayState extends State<PropertyImageDisplay> {
  final PropertyImageService _propertyImageService = PropertyImageService();
  PropertyImageModel? _firstImage;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFirstImage();
  }

  Future<void> _loadFirstImage() async {
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
        return;
      }

      final response =
          await _propertyImageService.getAllPropertyImagesByPropertyId(
        token,
        widget.propertyId,
      );

      if (response['statusCode'] == 200 && mounted) {
        final data = response['data'];
        if (data is List) {
          final List<dynamic> imagesData = data;
          final List<PropertyImageModel> images = imagesData
              .map((item) => PropertyImageModel.fromJson(item))
              .toList();

          // Find the first published image
          final publishedImages =
              images.where((img) => img.published == true).toList();

          if (mounted) {
            setState(() {
              _firstImage =
                  publishedImages.isNotEmpty ? publishedImages.first : null;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError || _firstImage == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.home,
          size: 40,
          color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _firstImage!.displayImageUrl,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCardBackground
                    : AppColors.lightCardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.broken_image,
                size: 40,
                color:
                    isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
              ),
            );
          },
        ),
      ),
    );
  }
}
