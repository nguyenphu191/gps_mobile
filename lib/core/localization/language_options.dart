/// The languages the app ships translations for.
///
/// One list, used by the onboarding picker, the settings picker and the
/// Settings row that shows which language is active — they used to keep three
/// copies of the same eight entries.
class LanguageOption {
  final String code;
  final String flag;

  /// English name, e.g. "Vietnamese".
  final String name;

  /// Name in the language itself, e.g. "Tiếng Việt".
  final String nativeName;

  const LanguageOption(this.code, this.flag, this.name, this.nativeName);
}

const kLanguageOptions = <LanguageOption>[
  LanguageOption('en', '🇺🇸', 'English', 'English'),
  LanguageOption('vi', '🇻🇳', 'Vietnamese', 'Tiếng Việt'),
  LanguageOption('ja', '🇯🇵', 'Japanese', '日本語'),
  LanguageOption('ko', '🇰🇷', 'Korean', '한국어'),
  LanguageOption('zh', '🇨🇳', 'Chinese Simplified', '中文简体'),
  LanguageOption('pt', '🇧🇷', 'Portuguese', 'Português'),
  LanguageOption('hi', '🇮🇳', 'Hindi', 'हिन्दी'),
  LanguageOption('ar', '🇸🇦', 'Arabic', 'العربية'),
];

/// English name of [code], falling back to the code itself for anything
/// unexpected so the UI never shows a blank.
String languageDisplayName(String code) {
  for (final option in kLanguageOptions) {
    if (option.code == code) return option.name;
  }
  return code.toUpperCase();
}
