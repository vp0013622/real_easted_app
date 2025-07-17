import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/services/property/propertyImageService.dart';
import 'package:inhabit_realties/pages/widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyImageUploadButton extends StatefulWidget {
  final PropertyModel property;
  final VoidCallback? onImageUploaded;

  const PropertyImageUploadButton({
    Key? key,
    required this.property,
    this.onImageUploaded,
  }) : super(key: key);

  @override
  State<PropertyImageUploadButton> createState() =>
      _PropertyImageUploadButtonState();
}

class _PropertyImageUploadButtonState extends State<PropertyImageUploadButton> {
  final PropertyImageService _propertyImageService = PropertyImageService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        await _uploadImage(File(pickedFile.path));
      }
    } catch (error) {
      _showSnackBar('Error picking image: $error', ContentType.failure);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await _propertyImageService.createPropertyImage(
        token,
        widget.property.id,
        imageFile,
      );

      if (response['statusCode'] == 200 && mounted) {
        _showSnackBar('Image uploaded successfully!', ContentType.success);
        widget.onImageUploaded?.call();
      } else {
        _showSnackBar(
          response['message'] ?? 'Failed to upload image',
          ContentType.failure,
        );
      }
    } catch (error) {
      _showSnackBar('Error uploading image: $error', ContentType.failure);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showSnackBar(String message, ContentType contentType) {
    if (mounted) {
      AppSnackBar.showSnackBar(
        context,
        contentType == ContentType.success ? 'Success' : 'Error',
        message,
        contentType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Property Images',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: Text(_isUploading ? 'Uploading...' : 'Add Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload images of your property to showcase it better',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
