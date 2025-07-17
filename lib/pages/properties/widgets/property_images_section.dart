import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/property/PropertyImageModel.dart';
import 'package:inhabit_realties/services/property/propertyImageService.dart';
import 'package:inhabit_realties/pages/widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:inhabit_realties/pages/properties/widgets/full_screen_image_viewer.dart';

class PropertyImagesSection extends StatefulWidget {
  final String propertyId;
  final bool isEditable;

  const PropertyImagesSection({
    super.key,
    required this.propertyId,
    this.isEditable = false,
  });

  @override
  State<PropertyImagesSection> createState() => _PropertyImagesSectionState();
}

class _PropertyImagesSectionState extends State<PropertyImagesSection> {
  final PropertyImageService _propertyImageService = PropertyImageService();
  final ImagePicker _picker = ImagePicker();

  List<PropertyImageModel> _images = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
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

          // Filter only published images
          final publishedImages =
              images.where((img) => img.published == true).toList();

          if (mounted) {
            setState(() {
              _images = publishedImages;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        AppSnackBar.showSnackBar(
            context, 'Error', 'Authentication required', ContentType.failure);
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final response = await _propertyImageService.createPropertyImage(
        token,
        widget.propertyId,
        File(image.path),
      );

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        AppSnackBar.showSnackBar(context, 'Success',
            'Image uploaded successfully', ContentType.success);
        await _loadImages(); // Reload images
      } else {
        AppSnackBar.showSnackBar(context, 'Error',
            response['message'] ?? 'Upload failed', ContentType.failure);
      }
    } catch (e) {
      AppSnackBar.showSnackBar(
          context, 'Error', 'Error uploading image: $e', ContentType.failure);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteImage(String imageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        AppSnackBar.showSnackBar(
            context, 'Error', 'Authentication required', ContentType.failure);
        return;
      }

      final response = await _propertyImageService.deletePropertyImageById(
        token,
        widget.propertyId,
        imageId,
      );

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        AppSnackBar.showSnackBar(context, 'Success',
            'Image deleted successfully', ContentType.success);
        await _loadImages(); // Reload images
      } else {
        AppSnackBar.showSnackBar(context, 'Error',
            response['message'] ?? 'Delete failed', ContentType.failure);
      }
    } catch (e) {
      AppSnackBar.showSnackBar(
          context, 'Error', 'Error deleting image: $e', ContentType.failure);
    }
  }

  void _showDeleteConfirmation(PropertyImageModel image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: Text('Are you sure you want to delete "${image.fileName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteImage(image.id);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Property Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
              ),
            ),
            if (widget.isEditable)
              IconButton(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate),
                tooltip: 'Add Image',
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (_images.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCardBackground
                  : AppColors.lightCardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library,
                  size: 48,
                  color: AppColors.greyColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No images uploaded yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.greyColor,
                  ),
                ),
                if (widget.isEditable) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add images',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              final image = _images[index];
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageViewer(
                                images: _images,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                      child: Image.network(
                        image.displayImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark
                                ? AppColors.darkCardBackground
                                : AppColors.lightCardBackground,
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: AppColors.greyColor,
                            ),
                          );
                        },
                        ),
                      ),
                    ),
                  ),
                  if (widget.isEditable)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _showDeleteConfirmation(image),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}
