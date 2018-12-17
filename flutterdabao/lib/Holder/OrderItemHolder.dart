import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:rxdart/rxdart.dart';

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

  Map<String,dynamic> toMap(){

    Map<String,dynamic> map = Map();

    map[OrderItem.titleKey] = title.value;
    map[OrderItem.priceKey] = price.value;
    map[OrderItem.descriptionKey] = description.value;
    map[OrderItem.qtyKey] = quantity.value;

    return map;

  }

}
