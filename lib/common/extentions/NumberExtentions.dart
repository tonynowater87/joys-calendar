import 'dart:math';

extension NumberExtentions on int {
  int toTaiwaneseYear() {
    return this - 1911;
  }

  /// https://stackoverflow.com/a/66473018/18902794
  String bytesToFileSizeString() {
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(this) / log(1024)).floor();
    return '${(this / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}
