import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';

class FormContainer extends StatelessWidget {
  final List<Widget> children;
  final GlobalKey<FormState> formKey;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? borderRadius;

  const FormContainer({
    super.key,
    required this.children,
    required this.formKey,
    this.margin = const EdgeInsets.all(20),
    this.padding = const EdgeInsets.symmetric(vertical: 20),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final shadowColor =
        isDark ? AppColors.darkShadowColor : AppColors.lightShadowColor;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius!),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Padding(
          padding: padding!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
