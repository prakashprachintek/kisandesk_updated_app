extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';

  /// Check if string is a valid email
  bool get isValidEmail => RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(this);

  /// Convert to int safely
  int get toInt => int.tryParse(this) ?? 0;
}
