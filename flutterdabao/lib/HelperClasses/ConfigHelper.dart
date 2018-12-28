import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/Route.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class ConfigHelper with HavingSubscriptionMixin {
  MutableProperty<User> currentUserProperty = MutableProperty<User>(null);

  MutableProperty<LatLng> currentLocationProperty =
      MutableProperty<LatLng>(null);

  MutableProperty<List<FoodTag>> currentUserFoodTagsProperty =
      MutableProperty<List<FoodTag>>(List());

  MutableProperty<List<Order>> currentUserRequestedOrdersProperty =
      MutableProperty<List<Order>>(List());

  // A users active Orders
  MutableProperty<List<Order>> currentUserAcceptedOrdersProperty =
      MutableProperty<List<Order>>(List());

  MutableProperty<List<Order>> currentUserDeliveredCompletedOrdersProperty =
      MutableProperty<List<Order>>(List());

  // All a users accepted Order which he is deliverying
  MutableProperty<List<Order>> currentUserDeliveringOrdersProperty =
      MutableProperty<List<Order>>(List());

  MutableProperty<List<Route>> currentUserOpenRoutesProperty =
      MutableProperty<List<Route>>(List());

  MutableProperty<double> _globalPricePerItem = MutableProperty<double>(0.5);
  MutableProperty<double> _globalFixedPrice = MutableProperty<double>(1.5);
  MutableProperty<int> _globalMinItemCount = MutableProperty<int>(2);

  String error;

  static ConfigHelper get instance =>
      _internal != null ? _internal : ConfigHelper._create();
  static ConfigHelper _internal;

  ConfigHelper._create() {
    _internal = this;
  }

  // Called once when app loads.
  appDidLoad() {
    disposeAndReset();

    subscription
        .add(currentUserFoodTagsProperty.bindTo(currentUserFoodTagProducer()));

    // Global Price forumala
    subscription.add(_globalPricePerItem.bindTo(globalConfigSettingsData()
        .map<double>((map) => map.containsKey("PRICE PER ITEM")
            ? map["PRICE PER ITEM"] + 0.0
            : 0.5)));

    subscription.add(_globalFixedPrice.bindTo(globalConfigSettingsData()
        .map<double>((map) =>
            map.containsKey("FIXED PRICE") ? map["FIXED PRICE"] + 0.0 : 1.5)));

    subscription.add(_globalMinItemCount.bindTo(globalConfigSettingsData()
        .map<int>((map) => map.containsKey("MIN QTY") ? map["MIN QTY"] : 2)));

    // get current RequestedOrder
    // get Current Accepted Orders
    subscription.add(currentUserRequestedOrdersProperty
        .bindTo(currentUserRequestedOrdersProducer()));
    subscription.add(currentUserAcceptedOrdersProperty
        .bindTo(currentUserAcceptedOrdersProducer()));

    // get current user deliveringOrderProperty;

    subscription.add(currentUserDeliveringOrdersProperty
        .bindTo(currentUserDeliveryingOrdersProducer()));

    subscription.add(currentUserDeliveredCompletedOrdersProperty
        .bindTo(currentUserDeliveredCompletedOrdersProducer()));

    // get Current open Routes
    subscription.add(
        currentUserOpenRoutesProperty.bindTo(currentUserOpenRoutesProducer()));
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Observable<List<FoodTag>> currentUserFoodTagProducer() {
    return currentUserProperty.producer.switchMap(
        (user) => user == null ? List<FoodTag>() : user.userFoodTags);
  }

  Observable<List<Order>> currentUserRequestedOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.statusKey, isEqualTo: orderStatus_Requested)
                .where(Order.creatorKey, isEqualTo: user.uid))
            .observable);
  }

  Observable<List<Route>> currentUserOpenRoutesProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Route>()
        : FirebaseCollectionReactive<Route>(Firestore.instance
                .collection("routes")
                .where(Route.statusKey, isEqualTo: routeStatus_Open)
                .where(Route.creatorKey, isEqualTo: user.uid))
            .observable);
  }

  Observable<List<Order>> currentUserAcceptedOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.statusKey, isEqualTo: orderStatus_Accepted)
                .where(Order.creatorKey, isEqualTo: user.uid))
            .observable);
  }

  Observable<List<Order>> currentUserDeliveryingOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.statusKey, isEqualTo: orderStatus_Accepted)
                .where(Order.delivererKey, isEqualTo: user.uid))
            .observable);
  }

  Observable<List<Order>> currentUserDeliveredCompletedOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.completedTimeKey, isGreaterThan: DateTimeHelper.convertDateTimeToString(DateTime.now().add(Duration(days: -2))))
                .where(Order.statusKey, isEqualTo: orderStatus_Completed)
                .where(Order.delivererKey, isEqualTo: user.uid))
            .observable);
  }

  Observable<Map<String, dynamic>> globalConfigSettingsData() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? Map()
        : Observable(Firestore.instance
            .collection("global")
            .document("settings")
            .snapshots()
            .map((doc) => doc.exists ? doc.data : Map())));
  }

  StreamSubscription<LatLng> location;

  void startListeningToCurrentLocation(Future<bool> askForPermission) async {
    location?.cancel();
    await askForPermission;
    var lastLocation =
        await LocationHelper.instance.location.getLastKnownPosition();

    if (lastLocation != null)
      currentLocationProperty.value =
          LatLng(lastLocation.latitude, lastLocation.longitude);

    location = currentLocationProperty
        .bindTo(LocationHelper.instance.onLocationChange());
  }

  double deliveryFeeCalculator({int numberOfItems}) {
    if (numberOfItems == 0) {
      return 0.0;
    } else {
      return _globalFixedPrice.value +
          ((numberOfItems - _globalMinItemCount.value) <= 0
                  ? 0
                  : (numberOfItems - _globalMinItemCount.value)) *
              _globalPricePerItem.value;
    }
  }
}
