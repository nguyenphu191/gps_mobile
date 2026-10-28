import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Primary CTA button using the CTA/01 linear gradient.
///
/// Use this for every primary action in the app so the blue gradient stays
/// consistent. Secondary / destructive actions keep their own solid colors.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;
  final double borderRadius;

  /// When true the button stretches to the full available width.
  /// Set to false for inline / trailing buttons that should size to content.
  final bool expand;

  /// Optional leading icon (drawn before the label).
  final Widget? icon;

  /// Optional trailing icon (drawn after the label).
  final Widget? trailing;

  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.height = 50,
    this.borderRadius = 10,
    this.expand = true,
    this.icon,
    this.trailing,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    final radius = BorderRadius.circular(borderRadius);

    return Opacity(
      opacity: enabled ? 1 : 0.7,
      child: Container(
        width: expand ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          gradient: AppConstants.ctaGradient,
          borderRadius: radius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: radius,
            child: Padding(
              padding:
                  padding ?? EdgeInsets.symmetric(horizontal: expand ? 16 : 20),
              child: Center(
                widthFactor: expand ? null : 1,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            IconTheme(
                              data: const IconThemeData(
                                color: Colors.white,
                                size: 20,
                              ),
                              child: icon!,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  textStyle ??
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          if (trailing != null) ...[
                            const SizedBox(width: 8),
                            IconTheme(
                              data: const IconThemeData(
                                color: Colors.white,
                                size: 20,
                              ),
                              child: trailing!,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
