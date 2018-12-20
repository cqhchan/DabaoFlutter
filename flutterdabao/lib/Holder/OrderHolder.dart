import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class OrderHolder {
  //Complusory
  MutableProperty<OrderMode> mode = MutableProperty(null);
  MutableProperty<LatLng> deliveryLocation = MutableProperty(null);
  MutableProperty<String> deliveryLocationDescription = MutableProperty(null);
  MutableProperty<String> foodTag = MutableProperty(null);
  MutableProperty<List<OrderItemHolder>> orderItems = MutableProperty(List());
  MutableProperty<DateTime> startDeliveryTime = MutableProperty(null);
  MutableProperty<double> deliveryFee = MutableProperty(0.0);

  //Optional
  MutableProperty<DateTime> endDeliveryTime = MutableProperty(null);
  MutableProperty<String> message = MutableProperty(null);

  Observable<double> maxPrice;
  Observable<double> finalPrice;
  Observable<int> numberOfItems;

  OrderHolder() {
    maxPrice = orderItems.producer.map((items) => items
        .map((order) => order.price.value * order.quantity.value)
        .toList()
        .reduce((price1, price2) => price1 + price2));

    finalPrice = Observable.combineLatest2<double,double,double>(maxPrice, deliveryFee.producer, (maxPrice, fee) => maxPrice + fee) ;

    numberOfItems = orderItems.producer.map((items) => items
        .map((order) => order.quantity.value)
        .toList()
        .reduce((qty1, qty2) => qty1 + qty2));
  }
}
