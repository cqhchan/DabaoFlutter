class StringHelper {
  static const String nullString = "UNKNOWN";

  static bool isNumeric(String str) {
    try {
      double.parse(str);
    } on FormatException {
      return false;
    } finally {
      return true;
    }
  }
}
