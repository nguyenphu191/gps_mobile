import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gpscamerastamp/core/analytics/analytics_events.dart';
import 'package:gpscamerastamp/core/analytics/analytics_service.dart';
import 'package:gpscamerastamp/core/di/service_locator.dart';
import 'package:gpscamerastamp/core/localization/app_localizations.dart';
import 'package:gpscamerastamp/core/localization/language_options.dart';
import 'package:gpscamerastamp/shared/widgets/circle_icon_button.dart';
import 'package:gpscamerastamp/shared/providers/language_provider.dart';

class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<LanguageSettingsScreen> createState() =>
      _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState
    extends ConsumerState<LanguageSettingsScreen> {
  late String _pendingCode;

  @override
  void initState() {
    super.initState();
    _pendingCode = ref.read(languageNotifierProvider).languageCode;
  }

  void _save() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              size: 44,
              elevated: true,
              onTap: () => context.pop(),
            ),
          ),
        ),
        title: Text(
          t.language,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              t.save,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: kLanguageOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lang = kLanguageOptions[index];
                final selected = lang.code == _pendingCode;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(languageNotifierProvider.notifier)
                        .setLanguage(lang.code);
                    getIt<AnalyticsService>().logEvent(
                      AnalyticsEvents.languageChanged,
                      parameters: {'language_code': lang.code},
                    );
                    setState(() => _pendingCode = lang.code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE2E8F0),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            lang.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}
