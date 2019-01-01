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


  static bool validatePhoneNumber(String value) {
    if (value.length != 8 || (value[0] != '8' && value[0] != '9')  || !isNumeric(value) ) {
      return false;
    }

    return true;
  }

  static String upperCaseWords(String str) {
    List<String> splitStr = str.toLowerCase().split(' ');
    for (var i = 0; i < splitStr.length; i++) {
      // You do not need to check if i is larger than splitStr length, as your for does that for you
      // Assign it back to the array
      splitStr[i] =
          splitStr[i].substring(0, 1).toUpperCase() + splitStr[i].substring(1);
    }
    // Directly return the joined string
    return splitStr.join(' ');
  }

  static String doubleToPriceString(double price) {
    if (price != null) {
      return "\$" + price.toStringAsFixed(2);
    } 
    return '';
  }

  static double stringPriceToDouble(String price) {
    return double.parse(price.replaceAll("\$", ""));
  }

  static String removeNewLine(String str) {
    return str.replaceAll("\n", " ");
  }
}
