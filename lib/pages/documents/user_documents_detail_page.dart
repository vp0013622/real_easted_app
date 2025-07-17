import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/controllers/document/DocumentController.dart';
import 'package:inhabit_realties/models/document/DocumentModel.dart';
import 'package:inhabit_realties/models/document/DocumentTypeModel.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/pages/widgets/appSnackBar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDocumentsDetailPage extends StatefulWidget {
  final UsersModel user;

  const UserDocumentsDetailPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserDocumentsDetailPage> createState() =>
      _UserDocumentsDetailPageState();
}

class _UserDocumentsDetailPageState extends State<UserDocumentsDetailPage> {
  final DocumentController _documentController = DocumentController();
  List<DocumentModel> _documents = [];
  List<DocumentTypeModel> _documentTypes = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Map to store expanded state for each document type
  Map<String, bool> _expandedSections = {};

  List<DocumentModel> get _filteredDocuments {
    if (_searchQuery.isEmpty) {
      return _documents;
    }
    return _documents
        .where((doc) =>
            doc.fileName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Group documents by document type
  Map<String, List<DocumentModel>> get _groupedDocuments {
    final Map<String, List<DocumentModel>> grouped = {};

    for (final doc in _filteredDocuments) {
      final documentType = _getDocumentTypeName(doc.documentTypeId);
      if (!grouped.containsKey(documentType)) {
        grouped[documentType] = [];
      }
      grouped[documentType]!.add(doc);
    }

    return grouped;
  }

  String _getDocumentTypeName(String documentTypeId) {
    try {
      final documentType =
          _documentTypes.firstWhere((type) => type.id == documentTypeId);
      return documentType.name;
    } catch (e) {
      return 'Unknown Type';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _loadDocumentTypes();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);

    try {
      // Get all documents and filter by user ID
      final response = await _documentController.getAllDocuments();

      if (response['statusCode'] == 200 && mounted) {
        final userDocuments =
            _documentController.getDocumentsByUserId(widget.user.id);

        setState(() {
          _documents = userDocuments;
          _isLoading = false;
        });

        // Initialize expanded state for new document types
        for (final doc in userDocuments) {
          final documentType = _getDocumentTypeName(doc.documentTypeId);
          if (!_expandedSections.containsKey(documentType)) {
            _expandedSections[documentType] = true; // Default to expanded
          }
        }
      } else {
        setState(() => _isLoading = false);
        AppSnackBar.showSnackBar(
          context,
          'Error',
          response['message'] ?? 'Failed to load documents',
          ContentType.failure,
        );
      }
    } catch (error) {
      setState(() => _isLoading = false);
      AppSnackBar.showSnackBar(
        context,
        'Error',
        'Exception loading documents: $error',
        ContentType.failure,
      );
    }
  }

  Future<void> _loadDocumentTypes() async {
    try {
      final response = await _documentController.getAllDocumentTypes();
      if (response['statusCode'] == 200 && mounted) {
        setState(() {
          _documentTypes = _documentController.documentTypes;
        });
      }
    } catch (error) {
      // Error handled silently
    }
  }

  Future<void> _deleteDocument(String documentId) async {
    final response = await _documentController.deleteDocument(documentId);
    if (response['statusCode'] == 200 && mounted) {
      AppSnackBar.showSnackBar(
        context,
        'Success',
        'Document deleted successfully',
        ContentType.success,
      );
      await _loadDocuments();
    } else {
      AppSnackBar.showSnackBar(
        context,
        'Error',
        response['message'] ?? 'Failed to delete document',
        ContentType.failure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[800] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.user.firstName} ${widget.user.lastName}\'s Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    '${widget.user.firstName[0]}${widget.user.lastName[0]}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.user.firstName} ${widget.user.lastName}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${widget.user.role}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_documents.length} docs',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cardColor,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Documents List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDocuments,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _groupedDocuments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.doc_text,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No documents found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This user hasn\'t uploaded any documents yet.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _groupedDocuments.length,
                          itemBuilder: (context, index) {
                            final documentType =
                                _groupedDocuments.keys.elementAt(index);
                            final documents = _groupedDocuments[documentType]!;
                            return _buildDocumentTypeSection(
                                documentType, documents);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeSection(
      String documentType, List<DocumentModel> documents) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[800] : Colors.white;
    final isExpanded = _expandedSections[documentType] ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedSections[documentType] = expanded;
          });
        },
        leading: Icon(
          _getDocumentTypeIcon(documentType),
          color: _getDocumentTypeColor(documentType),
          size: 28,
        ),
        title: Text(
          documentType,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Text(
          '${documents.length} document${documents.length != 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        children: documents.map((doc) => _buildDocumentCard(doc)).toList(),
      ),
    );
  }

  IconData _getDocumentTypeIcon(String documentType) {
    switch (documentType.toUpperCase()) {
      case 'IDENTITY_PROOF':
        return Icons.verified_user;
      case 'ADDRESS_PROOF':
        return Icons.home;
      case 'INCOME_PROOF':
        return Icons.attach_money;
      case 'PROPERTY_DOCUMENTS':
        return Icons.business;
      case 'AGREEMENT_DOCUMENTS':
        return Icons.description;
      default:
        return Icons.folder;
    }
  }

  Color _getDocumentTypeColor(String documentType) {
    switch (documentType.toUpperCase()) {
      case 'IDENTITY_PROOF':
        return Colors.blue;
      case 'ADDRESS_PROOF':
        return Colors.green;
      case 'INCOME_PROOF':
        return Colors.orange;
      case 'PROPERTY_DOCUMENTS':
        return Colors.purple;
      case 'AGREEMENT_DOCUMENTS':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDocumentCard(DocumentModel doc) {
    try {
      final isImage = doc.isImage;
      final isPdf = doc.isPdf;
      final isDoc = doc.isDocument;
      final icon = isImage
          ? Icons.image
          : isPdf
              ? Icons.picture_as_pdf
              : isDoc
                  ? Icons.description
                  : Icons.insert_drive_file;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          elevation: 2,
          child: ListTile(
            leading: Icon(icon, size: 32),
            title: Text(doc.fileName),
            subtitle: Text(
                '${doc.fileSizeFormatted} • ${doc.mimeType ?? 'Unknown type'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.blue),
                  onPressed: () async {
                    final url = doc.displayDocumentUrl;
                    if (url.isNotEmpty) {
                      try {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          AppSnackBar.showSnackBar(
                            context,
                            'Error',
                            'Could not download document. Please try again.',
                            ContentType.failure,
                          );
                        }
                      } catch (error) {
                        AppSnackBar.showSnackBar(
                          context,
                          'Error',
                          'Error downloading document: $error',
                          ContentType.failure,
                        );
                      }
                    } else {
                      AppSnackBar.showSnackBar(
                        context,
                        'Error',
                        'Document URL not available.',
                        ContentType.failure,
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Document'),
                        content: const Text(
                            'Are you sure you want to delete this document?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _deleteDocument(doc.id);
                    }
                  },
                ),
              ],
            ),
            onTap: () async {
              // Open the document URL in browser or viewer
              final url = doc.displayDocumentUrl;

              if (url.isNotEmpty) {
                try {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    AppSnackBar.showSnackBar(
                      context,
                      'Error',
                      'Could not open document. Please try again.',
                      ContentType.failure,
                    );
                  }
                } catch (error) {
                  AppSnackBar.showSnackBar(
                    context,
                    'Error',
                    'Error opening document: $error',
                    ContentType.failure,
                  );
                }
              } else {
                AppSnackBar.showSnackBar(
                  context,
                  'Error',
                  'Document URL not available.',
                  ContentType.failure,
                );
              }
            },
          ),
        ),
      );
    } catch (error) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          child: ListTile(
            leading: const Icon(Icons.error, size: 32, color: Colors.red),
            title: const Text('Error loading document'),
            subtitle: Text('Error: $error'),
          ),
        ),
      );
    }
  }
}
