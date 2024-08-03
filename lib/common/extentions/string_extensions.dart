extension StringExtensions on String {
  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }
}