import 'dart:math';

import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Voucher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class OrderHolder with HavingSubscriptionMixin {



  //Complusory
  MutableProperty<OrderMode> mode = MutableProperty(null);
  MutableProperty<LatLng> deliveryLocation;
  MutableProperty<String> deliveryLocationDescription;
  MutableProperty<String> foodTag;
  MutableProperty<String> status = MutableProperty(null);

  MutableProperty<int> progress = MutableProperty<int>(1);

  MutableProperty<bool> checkout = MutableProperty<bool>(false);

  MutableProperty<List<OrderItemHolder>> orderItems;
  MutableProperty<double> deliveryFee;

  //Optional
  MutableProperty<DateTime> startDeliveryTime = MutableProperty(null);

  MutableProperty<DateTime> cutOffDeliveryTime =
      MutableProperty(null); // for ASAP
  MutableProperty<DateTime> endDeliveryTime =
      MutableProperty(null); // For scheduled
  MutableProperty<String> message;

  MutableProperty<double> maxPrice = MutableProperty(0.0);
  MutableProperty<double> finalPrice = MutableProperty(0.0);
  MutableProperty<int> numberOfItems = MutableProperty(0);

  MutableProperty<Voucher> voucherProperty = MutableProperty(null);
  MutableProperty<double> voucherDeliveryFeeDiscount = MutableProperty(0.0);

  OrderHolder({Voucher voucher}) {
    deliveryLocation = MutableProperty(null);
    deliveryLocationDescription = MutableProperty(null);
    foodTag = MutableProperty(null);
    deliveryFee = MutableProperty(0.0);
    message = MutableProperty(null);
    orderItems = MutableProperty(List());

    voucherProperty.value = voucher;

    if (voucher != null) foodTag.value = voucher.foodTag.value;

    voucherProperty.producer
        .switchMap((voucher) => voucher == null
            ? Observable.just(0.0)
            : voucher.deliveryFeeDiscount)
        .listen((discount) {
      if (discount != null)
        voucherDeliveryFeeDiscount.value = discount;
      else {
        voucherDeliveryFeeDiscount.value = 0.0;
      }
    });

    maxPrice.bindTo(orderItems.producer.map((items) => items
        .map((order) => order.price.value * order.quantity.value)
        .toList()
        .reduce((price1, price2) => price1 + price2)));

    finalPrice.bindTo(Observable.combineLatest3<double, double, double, double>(
        maxPrice.producer,
        deliveryFee.producer,
        voucherDeliveryFeeDiscount.producer,
        (maxPrice, delvieryFee, discountFee) =>
            maxPrice + max(delvieryFee - discountFee, 0.0)));

    numberOfItems.bindTo(orderItems.producer.map((items) => items
        .map((order) => order.quantity.value)
        .toList()
        .reduce((qty1, qty2) => qty1 + qty2)));

    if (foodTag.value != null)
      progress = MutableProperty<int>(1);
    else
      progress = MutableProperty<int>(0);
  }

  OrderHolder.fromOrder({Order order, List<OrderItem> items}) {
    if (order.deliveryLocation.value != null) {
      deliveryLocation = MutableProperty(LatLng(
          order.deliveryLocation.value.latitude,
          order.deliveryLocation.value.longitude));
    } else {
      deliveryLocation = MutableProperty(null);
    }

    if (order.deliveryLocationDescription.value != null) {
      deliveryLocationDescription =
          MutableProperty(order.deliveryLocationDescription.value);
    } else {
      deliveryLocationDescription = MutableProperty(null);
    }

    if (order.foodTag.value != null) {
      foodTag = MutableProperty(order.foodTag.value);
    } else {
      foodTag = MutableProperty(null);
    }

    if (order.deliveryFee.value != null) {
      deliveryFee = MutableProperty(order.deliveryFee.value);
    } else {
      deliveryFee = MutableProperty(0.0);
    }

    if (order.message.value != null) {
      message = MutableProperty(order.message.value);
    } else {
      message = MutableProperty(null);
    }
    List<OrderItemHolder> temp = List();
    items.forEach((item) {
      temp.add(OrderItemHolder(
          title: item.name.value,
          description: item.description.value,
          price: item.price.value,
          quantity: item.quantity.value));
    });
    orderItems = MutableProperty(temp);

    voucherProperty.value = null;
    voucherProperty.producer
        .switchMap((voucher) => voucher == null
            ? Observable.just(0.0)
            : voucher.deliveryFeeDiscount)
        .listen((discount) {
      if (discount != null)
        voucherDeliveryFeeDiscount.value = discount;
      else {
        voucherDeliveryFeeDiscount.value = 0.0;
      }
    });

    maxPrice.bindTo(orderItems.producer.map((items) => items
        .map((order) => order.price.value * order.quantity.value)
        .toList()
        .reduce((price1, price2) => price1 + price2)));

    finalPrice.bindTo(Observable.combineLatest3<double, double, double, double>(
        maxPrice.producer,
        deliveryFee.producer,
        voucherDeliveryFeeDiscount.producer,
        (maxPrice, delvieryFee, discountFee) =>
            maxPrice + max(delvieryFee - discountFee, 0.0)));

    numberOfItems.bindTo(orderItems.producer.map((items) => items
        .map((order) => order.quantity.value)
        .toList()
        .reduce((qty1, qty2) => qty1 + qty2)));

    if (foodTag.value != null)
      progress = MutableProperty<int>(1);
    else
      progress = MutableProperty<int>(0);
  }
}
