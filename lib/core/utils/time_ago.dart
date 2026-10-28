import '../localization/app_localizations.dart';

/// "just now" / "5 minutes ago" / "3 hours ago" / "6 days ago".
///
/// Anything older than 4 weeks falls back to a plain date, because
/// "312 days ago" tells the reader nothing useful.
String timeAgo(AppLocalizations t, DateTime time) {
  final diff = DateTime.now().difference(time);

  if (diff.inMinutes < 1) return t.timeJustNow;
  if (diff.inHours < 1) return t.timeMinutesAgo('${diff.inMinutes}');
  if (diff.inDays < 1) return t.timeHoursAgo('${diff.inHours}');
  if (diff.inDays <= 28) return t.timeDaysAgo('${diff.inDays}');

  final two = (int n) => n.toString().padLeft(2, '0');
  return '${two(time.day)}/${two(time.month)}/${time.year}';
}
