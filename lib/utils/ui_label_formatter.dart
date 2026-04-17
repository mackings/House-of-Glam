String formatUiLabel(String? value, {String fallback = "N/A"}) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return fallback;

  final normalized =
      trimmed
          .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}',
          )
          .replaceAll('_', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

  if (normalized.isEmpty) return fallback;
  return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
}
