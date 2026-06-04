extension StringExtension on String {
  String toCamelCase() {
    final parts = toLowerCase().split('_');
    if (parts.isEmpty) return toLowerCase();
    return parts.first +
        parts
            .skip(1)
            .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
            .join();
  }
}
