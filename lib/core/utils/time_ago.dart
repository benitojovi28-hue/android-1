/// Relative time in French (e.g. "il y a 3 jours"), port of src/lib/jobs-time.ts.
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) return "à l'instant";
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return 'il y a $m minute${m > 1 ? 's' : ''}';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return 'il y a $h heure${h > 1 ? 's' : ''}';
  }
  if (diff.inDays < 30) {
    final d = diff.inDays;
    return 'il y a $d jour${d > 1 ? 's' : ''}';
  }
  if (diff.inDays < 365) {
    final mo = (diff.inDays / 30).floor();
    return 'il y a $mo mois';
  }
  final y = (diff.inDays / 365).floor();
  return 'il y a $y an${y > 1 ? 's' : ''}';
}
