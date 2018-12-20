import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class OrderHolder with HavingSubscriptionMixin {
  //Complusory
  MutableProperty<OrderMode> mode = MutableProperty(null);
  MutableProperty<LatLng> deliveryLocation = MutableProperty(null);
  MutableProperty<String> deliveryLocationDescription = MutableProperty(null);
  MutableProperty<String> foodTag = MutableProperty(null);
  MutableProperty<List<OrderItemHolder>> orderItems = MutableProperty(List());
  MutableProperty<double> deliveryFee = MutableProperty(0.0);

  //Optional
  MutableProperty<DateTime> startDeliveryTime = MutableProperty(null);
    
  MutableProperty<DateTime> cutOffDeliveryTime = MutableProperty(null); // for ASAP
  MutableProperty<DateTime> endDeliveryTime = MutableProperty(null); // For scheduled
  MutableProperty<String> message = MutableProperty(null);

  MutableProperty<double> maxPrice = MutableProperty(0.0);
  MutableProperty<double> finalPrice = MutableProperty(0.0);
  MutableProperty<int> numberOfItems = MutableProperty(0);

  OrderHolder() {
    maxPrice.bindTo(orderItems.producer.map((items) => items
        .map((order) => order.price.value * order.quantity.value)
        .toList()
        .reduce((price1, price2) => price1 + price2)));

    finalPrice.bindTo(Observable.combineLatest2<double, double, double>(
        orderItems.producer.map((items) => items
            .map((order) => order.price.value * order.quantity.value)
            .toList()
            .reduce((price1, price2) => price1 + price2)),
        deliveryFee.producer,
        (maxPrice, fee) => maxPrice + fee));

    numberOfItems.bindTo(orderItems.producer.map((items) => items
        .map((order) => order.quantity.value)
        .toList()
        .reduce((qty1, qty2) => qty1 + qty2)));
  }
}
