import 'package:flutter/material.dart';
import '../../../core/theme/aurora.dart';
import '../../../core/localization/app_localizations.dart';

class DetailSectionLabel extends StatelessWidget {
  final String text;
  const DetailSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        text,
        style: Aurora.text(
          18,
          weight: FontWeight.w800,
          color: Aurora.darkText,
        ).copyWith(letterSpacing: -0.3),
      ),
      const SizedBox(width: 8),
      Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Aurora.secondary,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}

class DetailExpandableText extends StatefulWidget {
  final String text;
  const DetailExpandableText({super.key, required this.text});

  @override
  State<DetailExpandableText> createState() => _DetailExpandableTextState();
}

class _DetailExpandableTextState extends State<DetailExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 260),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            widget.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              color: Aurora.subText,
              height: 1.65,
            ),
          ),
          secondChild: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 14.5,
              color: Aurora.subText,
              height: 1.65,
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded
                ? AppLocalizations.of(context).showLess
                : AppLocalizations.of(context).readMore,
            style: const TextStyle(
              fontSize: 14,
              color: Aurora.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
