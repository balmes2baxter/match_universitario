String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'hace ${diff.inDays} d';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return 'hace $weeks sem';
  final months = (diff.inDays / 30).floor();
  return 'hace $months mes${months == 1 ? '' : 'es'}';
}
