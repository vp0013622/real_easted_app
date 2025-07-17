import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/controllers/document/DocumentController.dart';
import 'package:inhabit_realties/controllers/user/userController.dart';
import 'package:inhabit_realties/models/document/DocumentTypeModel.dart';
import 'package:inhabit_realties/models/auth/UsersModel.dart';
import 'package:inhabit_realties/pages/documents/widgets/document_upload_button.dart';

class AddNewDocumentAdminButton extends StatefulWidget {
  final VoidCallback? onDocumentAdded;

  const AddNewDocumentAdminButton({
    super.key,
    this.onDocumentAdded,
  });

  @override
  State<AddNewDocumentAdminButton> createState() =>
      _AddNewDocumentAdminButtonState();
}

class _AddNewDocumentAdminButtonState extends State<AddNewDocumentAdminButton> {
  final DocumentController _documentController = DocumentController();
  final UserController _userController = UserController();

  List<UsersModel> _users = [];
  List<DocumentTypeModel> _documentTypes = [];
  bool _isLoadingUsers = false;
  bool _isLoadingDocumentTypes = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUsers(),
      _loadDocumentTypes(),
    ]);
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);

    try {
      final response = await _userController.getAllUsers();
      if (response['statusCode'] == 200 && mounted) {
        setState(() {
          _users = (response['data'] as List)
              .map((item) => UsersModel.fromJson(item))
              .toList();
          _isLoadingUsers = false;
        });
      } else {
        setState(() => _isLoadingUsers = false);
      }
    } catch (error) {
      setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _loadDocumentTypes() async {
    setState(() => _isLoadingDocumentTypes = true);

    try {
      final response = await _documentController.getAllDocumentTypes();
      if (response['statusCode'] == 200 && mounted) {
        setState(() {
          _documentTypes = response['data'] ?? [];
          _isLoadingDocumentTypes = false;
        });
      } else {
        setState(() => _isLoadingDocumentTypes = false);
      }
    } catch (error) {
      setState(() => _isLoadingDocumentTypes = false);
    }
  }

  void _showAddDocumentDialog() {
    UsersModel? selectedUser;
    DocumentTypeModel? selectedDocumentType;
    final userSearchController = TextEditingController();
    final documentTypeSearchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Document'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User Selection Dropdown
                DropdownButtonFormField2<UsersModel?>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Select User',
                    hintText: 'Choose a user...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  value: selectedUser,
                  items: _users.map((user) {
                    return DropdownMenuItem<UsersModel>(
                      value: user,
                      child: Text('${user.firstName} ${user.lastName}'),
                    );
                  }).toList(),
                  onChanged: (UsersModel? value) {
                    setState(() {
                      selectedUser = value;
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.only(right: 8),
                    height: 48,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                  ),
                  dropdownSearchData: DropdownSearchData(
                    searchController: userSearchController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: userSearchController,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          hintText: 'Search users...',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      final user = item.value!;
                      final fullName =
                          '${user.firstName} ${user.lastName}'.toLowerCase();
                      final email = user.email.toLowerCase();
                      return fullName.contains(searchValue.toLowerCase()) ||
                          email.contains(searchValue.toLowerCase());
                    },
                  ),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                  ),
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      userSearchController.clear();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Document Type Selection Dropdown
                DropdownButtonFormField2<DocumentTypeModel?>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Document Type',
                    hintText: 'Choose document type...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  value: selectedDocumentType,
                  items: _documentTypes.map((docType) {
                    return DropdownMenuItem<DocumentTypeModel>(
                      value: docType,
                      child: Text(docType.name),
                    );
                  }).toList(),
                  onChanged: (DocumentTypeModel? value) {
                    setState(() {
                      selectedDocumentType = value;
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.only(right: 8),
                    height: 48,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                  ),
                  dropdownSearchData: DropdownSearchData(
                    searchController: documentTypeSearchController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: documentTypeSearchController,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          hintText: 'Search document types...',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      final docType = item.value!;
                      return docType.name
                              .toLowerCase()
                              .contains(searchValue.toLowerCase()) ||
                          docType.description
                              .toLowerCase()
                              .contains(searchValue.toLowerCase());
                    },
                  ),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                  ),
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      documentTypeSearchController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: (selectedUser != null && selectedDocumentType != null)
                  ? () {
                      Navigator.pop(context);
                      _navigateToDocumentUpload(
                          selectedUser!, selectedDocumentType!);
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDocumentUpload(
      UsersModel user, DocumentTypeModel documentType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title:
                Text('Upload Document for ${user.firstName} ${user.lastName}'),
          ),
          body: DocumentUploadButton(
            userId: user.id,
            onDocumentUploaded: () {
              Navigator.pop(context);
              widget.onDocumentAdded?.call();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.lightDarkText : AppColors.lightBackground;
    final textColor =
        isDark ? AppColors.darkWhiteText : AppColors.lightDarkText;
    final shadowColor =
        isDark ? AppColors.lightCardBackground : AppColors.darkCardBackground;

    return InkWell(
        onTap: _showAddDocumentDialog,
        child: Container(
          padding:
              const EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                  blurRadius: 2,
                  offset: const Offset(0, 0),
                  color: shadowColor.withOpacity(0.3)),
            ],
          ),
          child: Text(
            "Add Document",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: textColor,
                ),
          ),
        ));
  }
}
