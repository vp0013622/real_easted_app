import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/document/DocumentController.dart';
import 'package:inhabit_realties/models/document/DocumentTypeModel.dart';
import 'package:inhabit_realties/pages/widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentUploadButton extends StatefulWidget {
  final String userId;
  final VoidCallback? onDocumentUploaded;
  final bool showDocumentTypeSelector;

  const DocumentUploadButton({
    Key? key,
    required this.userId,
    this.onDocumentUploaded,
    this.showDocumentTypeSelector = true,
  }) : super(key: key);

  @override
  State<DocumentUploadButton> createState() => _DocumentUploadButtonState();
}

class _DocumentUploadButtonState extends State<DocumentUploadButton> {
  final DocumentController _documentController = DocumentController();
  bool _isUploading = false;
  bool _isLoadingDocumentTypes = false;
  List<DocumentTypeModel> _documentTypes = [];
  DocumentTypeModel? _selectedDocumentType;
  File? _selectedFile;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _loadDocumentTypes();
  }

  Future<void> _loadDocumentTypes() async {
    setState(() => _isLoadingDocumentTypes = true);

    try {
      final response = await _documentController.getAllDocumentTypes();

      if (response['statusCode'] == 200 && mounted) {
        setState(() {
          _documentTypes = response['data'] ?? [];
          if (_documentTypes.isNotEmpty) {
            _selectedDocumentType = _documentTypes.first;
          }
        });
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.showSnackBar(
          context,
          'Error',
          'Failed to load document types: $error',
          ContentType.failure,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDocumentTypes = false);
      }
    }
  }

  Future<void> _pickDocument() async {
    if (_selectedDocumentType == null) {
      AppSnackBar.showSnackBar(
        context,
        'Error',
        'Please select a document type first',
        ContentType.failure,
      );
      return;
    }

    try {
      // Normalize extensions for file picker (remove dots if present)
      final normalizedExtensions = _selectedDocumentType!.allowedExtensions
          .map((ext) => ext.replaceAll('.', ''))
          .toList();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: normalizedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.path != null) {
          final file = File(pickedFile.path!);
          setState(() {
            _selectedFile = file;
            _selectedFileName = pickedFile.name;
          });
        } else {
          AppSnackBar.showSnackBar(
            context,
            'Error',
            'Unable to access the selected file. Please try again.',
            ContentType.failure,
          );
        }
      }
    } catch (error) {
      AppSnackBar.showSnackBar(
        context,
        'Error',
        'Error picking file: $error',
        ContentType.failure,
      );
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      AppSnackBar.showSnackBar(
        context,
        'Error',
        'Please select a file first',
        ContentType.failure,
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Check if file exists before validation
      if (!_selectedFile!.existsSync()) {
        AppSnackBar.showSnackBar(
          context,
          'Error',
          'Selected file does not exist or is not accessible',
          ContentType.failure,
        );
        return;
      }

      // Validate file
      final validation = _documentController.validateFileForDocumentType(
        _selectedFile!,
        _selectedDocumentType!,
      );

      if (!validation['isValid']) {
        AppSnackBar.showSnackBar(
          context,
          'Error',
          validation['message'],
          ContentType.failure,
        );
        return;
      }

      final response = await _documentController.uploadDocument(
        widget.userId,
        _selectedDocumentType!.id,
        _selectedFile!,
      );

      if (response['statusCode'] == 200 && mounted) {
        AppSnackBar.showSnackBar(
          context,
          'Success',
          'Document uploaded successfully!',
          ContentType.success,
        );
        // Reset selection
        setState(() {
          _selectedFile = null;
          _selectedFileName = null;
        });
        widget.onDocumentUploaded?.call();
      } else {
        AppSnackBar.showSnackBar(
          context,
          'Error',
          response['message'] ?? 'Failed to upload document',
          ContentType.failure,
        );
      }
    } catch (error) {
      AppSnackBar.showSnackBar(
        context,
        'Error',
        'Error uploading document: $error',
        ContentType.failure,
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final secondaryTextColor =
        isDark ? AppColors.greyColor : AppColors.greyColor2;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(textColor),
              const SizedBox(height: 32),

              // Document Type Selection
              if (widget.showDocumentTypeSelector) ...[
                _buildDocumentTypeSection(textColor, secondaryTextColor),
                const SizedBox(height: 24),
              ],

              // File Selection Section
              _buildFileSelectionSection(textColor, secondaryTextColor),
              const SizedBox(height: 24),

              // File Requirements Section
              if (_selectedDocumentType != null) ...[
                _buildRequirementsSection(textColor, secondaryTextColor),
                const SizedBox(height: 32),
              ],

              // Upload Button
              _buildUploadButton(textColor),
              const SizedBox(height: 24),

              // Help Text
              _buildHelpText(secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.upload_file_outlined,
                color: AppColors.brandPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Document',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select your document and upload it securely',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentTypeSection(Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Icon(
                Icons.category_outlined,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Document Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingDocumentTypes)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_documentTypes.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No document types available',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DocumentTypeModel>(
                  value: _selectedDocumentType,
                  isExpanded: true,
                  menuMaxHeight: 300,
                  hint: Text(
                    'Select document type',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  items: _documentTypes.map((DocumentTypeModel type) {
                    return DropdownMenuItem<DocumentTypeModel>(
                      value: type,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (type.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                type.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (DocumentTypeModel? newValue) {
                    setState(() {
                      _selectedDocumentType = newValue;
                      // Clear file selection when document type changes
                      _selectedFile = null;
                      _selectedFileName = null;
                    });
                  },
                  dropdownColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkCardBackground
                      : Colors.white,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileSelectionSection(Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Icon(
                Icons.file_upload_outlined,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Select File',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedFile == null)
            GestureDetector(
              onTap: _selectedDocumentType != null ? _pickDocument : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedDocumentType != null
                        ? AppColors.brandPrimary.withOpacity(0.3)
                        : Colors.grey.shade300,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: _selectedDocumentType != null
                      ? AppColors.brandPrimary.withOpacity(0.05)
                      : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: _selectedDocumentType != null
                          ? AppColors.brandPrimary
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to select a file',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedDocumentType != null
                            ? textColor
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PDF, DOC, DOCX, XLS, XLSX, TXT',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.brandPrimary.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: AppColors.brandPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFileName ?? 'Selected File',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _clearSelection,
                    icon: Icon(
                      Icons.close,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'File Requirements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRequirementItem(
            'Allowed formats',
            _selectedDocumentType!.allowedExtensionsFormatted,
            Icons.file_present_outlined,
            Colors.blue.shade700,
          ),
          const SizedBox(height: 8),
          _buildRequirementItem(
            'Maximum size',
            _selectedDocumentType!.maxFileSizeFormatted,
            Icons.storage_outlined,
            Colors.blue.shade700,
          ),
          if (_selectedDocumentType!.isRequired) ...[
            const SizedBox(height: 8),
            _buildRequirementItem(
              'Status',
              'This document is required',
              Icons.priority_high,
              Colors.red.shade600,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(Color textColor) {
    final bool canUpload =
        _selectedDocumentType != null && _selectedFile != null && !_isUploading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canUpload ? _uploadDocument : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canUpload ? AppColors.brandPrimary : Colors.grey.shade300,
          foregroundColor: canUpload ? Colors.white : Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: canUpload ? 4 : 0,
        ),
        child: _isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file,
                    size: 20,
                    color: canUpload ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upload Document',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: canUpload ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHelpText(Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: secondaryTextColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Upload important documents like contracts, agreements, certificates, or any other required files. Make sure your file meets the requirements above.',
              style: TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
