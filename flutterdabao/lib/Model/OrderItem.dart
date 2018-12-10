import 'package:flutterdabao/HelperClasses/StringHelper.dart';

class OrderItem {
  final String titleKey = "T";
  final String qtyKey = "QTY";
  final String priceKey = "P";
  final String descriptionKey = "D";

  String name;
  double price;
  int quantity;
  String description;

  OrderItem(this.name, this.price, this.description, this.quantity);

  OrderItem.fromMap(Map<String, dynamic> map) {
    if (map.containsKey(titleKey)) {
      name = map[titleKey];
    } else {
      name = StringHelper.nullString;
    }

    if (map.containsKey(descriptionKey)) {
      description = map[descriptionKey];
    } else {
      description = StringHelper.nullString;
    }

    if (map.containsKey(qtyKey)) {
      quantity = map[qtyKey];
    } else {
      quantity = -1;
    }

    if (map.containsKey(priceKey)) {
      price = map[priceKey];
    } else {
      price = -1;
    }
  }
}
