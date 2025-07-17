import 'package:flutter/material.dart';

class FormFieldContainer extends StatelessWidget {
  final Widget child;

  const FormFieldContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: child,
    );
  }
}
