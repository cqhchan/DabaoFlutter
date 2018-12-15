import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';

class OrderItemHolder {
  MutableProperty<double> price;
  MutableProperty<String> title;
  MutableProperty<String> description;
  MutableProperty<int> quantity;

  OrderItemHolder({
    String title,
    String description,
    double price,
    int quantity,
  }) {
    this.price = MutableProperty(price);
    this.title = MutableProperty(title);
    this.description = MutableProperty(description);
    this.quantity = MutableProperty(quantity);
  }
}
