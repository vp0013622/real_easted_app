import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/pages/documents/widgets/document_upload_button.dart';

class AddNewDocumentButton extends StatefulWidget {
  final String userId;
  final VoidCallback? onDocumentAdded;

  const AddNewDocumentButton({
    super.key,
    required this.userId,
    this.onDocumentAdded,
  });

  @override
  State<AddNewDocumentButton> createState() => _AddNewDocumentButtonState();
}

class _AddNewDocumentButtonState extends State<AddNewDocumentButton> {
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
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Upload New Document'),
                ),
                body: DocumentUploadButton(
                  userId: widget.userId,
                  onDocumentUploaded: () {
                    Navigator.pop(context);
                    widget.onDocumentAdded?.call();
                  },
                ),
              ),
            ),
          );

          // If a document was added successfully, refresh the documents list
          if (result == true) {
            widget.onDocumentAdded?.call();
          }
        },
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
