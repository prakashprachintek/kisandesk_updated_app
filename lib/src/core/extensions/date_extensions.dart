extension DateExtensions on DateTime {
  /// Format as dd/MM/yyyy
  String get formattedDate =>
      '${this.day.toString().padLeft(2, '0')}/${this.month.toString().padLeft(2, '0')}/${this.year}';

  /// Format as yyyy-MM-dd
  String get isoDate => '${this.year}-${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}';
}
