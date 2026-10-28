import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/aurora.dart';

/// Height the floating nav bar occupies, including its bottom margin.
/// Screens inside the shell get this much extra bottom padding.
const double kAppBottomNavHeight = 88;

class _NavItem {
  final IconData icon;
  final String Function(AppLocalizations) label;

  const _NavItem(this.icon, this.label);
}

const _items = <_NavItem>[
  _NavItem(Icons.home_rounded, _homeLabel),
  _NavItem(Icons.map_rounded, _galleryLabel),
  _NavItem(Icons.group_rounded, _friendLabel),
  _NavItem(Icons.tune_rounded, _settingLabel),
];

String _homeLabel(AppLocalizations t) => t.home;
String _galleryLabel(AppLocalizations t) => t.gallery;
String _friendLabel(AppLocalizations t) => t.friends;
String _settingLabel(AppLocalizations t) => t.settings;

/// Floating glass pill navigation. Purely presentational — the shell owns
/// which tab is active and what tapping one does.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Aurora.primary.withValues(alpha: 0.22),
            blurRadius: 32,
            spreadRadius: -6,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Aurora.secondary.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white),
            ),
            child: LayoutBuilder(
              builder: (context, c) {
                // Slots animate their widths, and one gradient pill glides
                // under the active slot, so switching tabs flows instead of
                // popping.
                final total = c.maxWidth;
                final selW = total * 0.34;
                final otherW = (total - selW) / (_items.length - 1);
                final widths = [
                  for (var i = 0; i < _items.length; i++)
                    i == currentIndex ? selW : otherW,
                ];
                var left = 0.0;
                for (var i = 0; i < currentIndex; i++) {
                  left += widths[i];
                }
                const dur = Duration(milliseconds: 320);
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: dur,
                      curve: Curves.easeOutCubic,
                      left: left + 4,
                      width: selW - 8,
                      top: 9,
                      height: 46,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: Aurora.primaryGradient,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Aurora.primary.withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _items.length; i++)
                          AnimatedContainer(
                            duration: dur,
                            curve: Curves.easeOutCubic,
                            width: widths[i],
                            child: _NavTab(
                              item: _items[i],
                              label: _items[i].label(t),
                              selected: i == currentIndex,
                              onTap: () {
                                if (i != currentIndex) {
                                  HapticFeedback.selectionClick();
                                }
                                onTap(i);
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.1 : 1,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(
                  item.icon,
                  size: 24,
                  color: selected ? Colors.white : const Color(0xFF7B7487),
                ),
              ),
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Aurora.text(
                              12,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
