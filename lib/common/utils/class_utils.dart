class ClassUtils {
  static T? tryCast<T>(var x) {
    try {
      return x as T;
    } on TypeError catch (_) {
      return null;
    }
  }
}
