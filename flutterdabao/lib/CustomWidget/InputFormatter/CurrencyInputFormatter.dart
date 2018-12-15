import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';

//TODO there is a bug that crashes is sometimes
class CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newNumberString;
    int newNumber;

    if (newValue.text.isEmpty)
      return newValue.copyWith(
          text: '\$0.00', selection: new TextSelection.collapsed(offset: 5));

    if (oldValue.text.length > newValue.text.length) {
      int numberOfDeleted = oldValue.text.length - newValue.text.length;
      String number = oldValue.text.replaceAll('\$', "").replaceAll('\.', "");

      newNumberString = number.substring(
          0,
          number.length >= numberOfDeleted
              ? number.length - numberOfDeleted
              : 0);
    } else {
      newNumberString = newValue.text
          .replaceAll('\$0.', "")
          .replaceAll('\$', "")
          .replaceAll('\.', '');
    }
    try {
      newNumber = int.parse(newNumberString);
    } catch (e) {
      newNumber = 0;
    }

    double newdouble = newNumber.toDouble() / 100;

    String newprice =  StringHelper.doubleToPriceString(newdouble);

    return newValue.copyWith(
        text: newprice,
        selection: new TextSelection.collapsed(offset: newValue.text.length));
  }
}
