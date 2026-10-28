import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

class FlashButton extends StatelessWidget {
  const FlashButton({super.key, required this.flashMode, required this.onTap});

  final FlashMode flashMode;
  final VoidCallback onTap;

  IconData get _flashIcon {
    switch (flashMode) {
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.off:
        return Icons.flash_off_rounded;
      default:
        return Icons.flash_auto_rounded;
    }
  }

  Color get _flashColor {
    switch (flashMode) {
      case FlashMode.always:
        return const Color(0xFFFBBF24);
      case FlashMode.off:
        return Colors.white38;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    String label;
    switch (flashMode) {
      case FlashMode.always:
        label = t.onLabel;
        break;
      case FlashMode.off:
        label = t.offLabel;
        break;
      default:
        label = t.autoLabel;
        break;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: flashMode == FlashMode.always
              ? const Color(0xFFFBBF24).withValues(alpha: 0.25)
              : Colors.black38,
          borderRadius: BorderRadius.circular(12),
          border: flashMode == FlashMode.always
              ? Border.all(color: const Color(0xFFFBBF24), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_flashIcon, color: _flashColor, size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: _flashColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
