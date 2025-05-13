import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final TextStyle? textStyle;
  final Widget? icon;
  final MainAxisSize mainAxisSize;
  final bool expanded;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.textStyle,
    this.icon,
    this.mainAxisSize = MainAxisSize.min,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
      ),
      child: Row(
        mainAxisSize: mainAxisSize,
        children: [
          if (icon != null) icon!,
          if (icon != null) const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
