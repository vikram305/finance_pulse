extension StringExtension on String {
  String capitalizeWords() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
