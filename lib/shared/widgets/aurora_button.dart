import 'package:flutter/material.dart';

import '../../core/theme/aurora.dart';

/// Pill CTA with the Aurora violet→pink gradient and glow.
/// Pass [enabled] false for the greyed look while keeping [onTap] active
/// (e.g. to show a "please select" dialog).
class AuroraButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final double height;
  final IconData? trailingIcon;
  final bool isLoading;

  const AuroraButton({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.height = 56,
    this.trailingIcon,
    this.isLoading = false,
  });

  @override
  State<AuroraButton> createState() => _AuroraButtonState();
}

class _AuroraButtonState extends State<AuroraButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.enabled ? Colors.white : const Color(0xFFADB5BD);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: widget.enabled ? Aurora.primaryGradient : null,
            color: widget.enabled ? null : Aurora.disabled,
            borderRadius: BorderRadius.circular(999),
            boxShadow: widget.enabled ? Aurora.glow : null,
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: Aurora.text(16, weight: FontWeight.w800, color: fg),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.trailingIcon, size: 18, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
