import 'package:flutter/material.dart';
import 'package:inhabit_realties/pages/widgets/loader.dart';

class AppSpinner extends StatefulWidget {
  final double? size;
  final double? strokeWidth;

  const AppSpinner({super.key, this.size = 32.0, this.strokeWidth = 3.0});

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Loader(size: widget.size, strokeWidth: widget.strokeWidth),
    );
  }
}
