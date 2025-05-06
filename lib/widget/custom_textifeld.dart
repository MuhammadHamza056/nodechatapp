import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final bool isPasswordField;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.errorText,
    this.keyboardType,
    this.obscureText,
    this.isPasswordField = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.contentPadding,
    this.maxLines = 1,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.borderColor,
    this.onTap,
    this.focusedBorderColor,
    this.borderRadius = 8.0,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText!,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      validator: widget.validator,
      maxLines: widget.maxLines,
      autofocus: widget.autofocus,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey),
        labelText: widget.labelText,
       labelStyle: TextStyle(color: Colors.grey),
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon:
            widget.isPasswordField
                ? IconButton(
                  icon: Icon(
                    widget.obscureText!
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: widget.onTap,
                )
                : widget.suffixIcon,
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? theme.dividerColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? theme.dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
      ),
    );
  }
}
