import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:inhabit_realties/providers/login_page_provider.dart';

class FormTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool? enabled;
  final TextInputType? keyboardType;
  final bool autofocus;
  final bool obscureText;

  const FormTextField({
    super.key,
    required this.textEditingController,
    required this.labelText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.keyboardType,
    this.autofocus = false,
    this.obscureText = false,
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  bool _obscureText = true;
  static const _borderRadius = BorderRadius.all(Radius.circular(10.0));
  static const _contentPadding = EdgeInsets.only(top: 20, left: 15, right: 15);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isPassword = widget.labelText == LoginPageProvider.password;

    return Padding(
      padding: _contentPadding,
      child: TextFormField(
        controller: widget.textEditingController,
        validator: widget.validator,
        obscureText: isPassword ? _obscureText : widget.obscureText,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 15,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: BorderSide(
              color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: _borderRadius,
            borderSide: BorderSide(
              color: isDark ? AppColors.darkWhiteText : AppColors.lightDarkText,
            ),
          ),
          labelText: widget.labelText,
          prefixIcon:
              widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon:
              widget.suffixIcon != null && isPassword
                  ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }
}
