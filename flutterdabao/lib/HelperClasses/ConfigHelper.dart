import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:flutterdabao/Model/DabaoerReward.dart';
import 'package:flutterdabao/Model/DabaoeeReward.dart';

import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/Promotion.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Model/Voucher.dart';
import 'package:flutterdabao/Model/Wallet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibrate/vibrate.dart';

class ConfigHelper with HavingSubscriptionMixin {
  MutableProperty<User> currentUserProperty = MutableProperty<User>(null);

  MutableProperty<LatLng> currentLocationProperty =
      MutableProperty<LatLng>(null);

  MutableProperty<Wallet> currentUserWalletProperty =
      MutableProperty<Wallet>(null);

  MutableProperty<List<FoodTag>> currentUserFoodTagsProperty =
      MutableProperty<List<FoodTag>>(List());

  MutableProperty<List<Order>> currentUserRequestedOrdersProperty =
      MutableProperty<List<Order>>(List());

  // A users active Orders
  MutableProperty<List<Order>> currentUserAcceptedOrdersProperty =
      MutableProperty<List<Order>>(List());
  // A users Orders from the past week
  MutableProperty<List<Order>> currentUserPastWeekCompletedOrdersProperty =
      MutableProperty<List<Order>>(List());
  LatLng lastLocation;
  // A users Orders from the past week
  MutableProperty<List<Order>> currentUserPastWeekCanceledOrdersProperty =
      MutableProperty<List<Order>>(List());

  MutableProperty<List<Order>> currentUserDeliveredCompletedOrdersProperty =
      MutableProperty<List<Order>>(List());

  // All a users accepted Order which he is deliverying
  MutableProperty<List<Order>> currentUserDeliveringOrdersProperty =
      MutableProperty<List<Order>>(List());

  MutableProperty<List<DabaoRoute.Route>> currentUserRoutesPastDayProperty =
      MutableProperty<List<DabaoRoute.Route>>(List());

  MutableProperty<DabaoerReward> currentDabaoerRewards =
      MutableProperty<DabaoerReward>(null);

  MutableProperty<DabaoeeReward> currentDabaoeeRewards =
      MutableProperty<DabaoeeReward>(null);

  MutableProperty<List<Channel>> currentUserChannelProperty =
      MutableProperty<List<Channel>>(List());

  MutableProperty<List<Promotion>> currentPromotionsProperty =
      MutableProperty<List<Promotion>>(List());

  MutableProperty<double> _globalPricePerItem = MutableProperty<double>(0.5);
  MutableProperty<double> _globalFixedPrice = MutableProperty<double>(1.5);
  MutableProperty<int> _globalMinItemCount = MutableProperty<int>(2);
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  String error;

  static ConfigHelper get instance =>
      _internal != null ? _internal : ConfigHelper._create();
  static ConfigHelper _internal;

  ConfigHelper._create() {
    _internal = this;
  }
  bool canVibrate = false;
  // Called once when app loads.
  appDidLoad() {
    disposeAndReset();

    Vibrate.canVibrate.then((canVibrate) => this.canVibrate = canVibrate);

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

    subscription.add(Observable.combineLatest2<LatLng, User, LatLng>(
        currentLocationProperty.producer, currentUserProperty.producer,
        (location, user) {
      if (location == null || user == null) {
        return null;
      }

      if (lastLocation == null) {
        return location;
      }

      if (LocationHelper.calculateDistancFromSelf(lastLocation.latitude,
              lastLocation.longitude, location.latitude, location.longitude) >
          0.1) {
        return location;
      }

      return null;
    }).listen((location) {
      if (location != null) {
        lastLocation = location;
        DateTime date = DateTime.now();
        String dayOfWeek = formatDate(date, [DD]).toUpperCase();
        String dateFormat =
            formatDate(date, [yyyy, '-', mm, '-', dd]).toUpperCase();
        GeoPoint geoPoint = GeoPoint(location.latitude, location.longitude);
        Firestore.instance
            .collection("locations")
            .document(currentUserProperty.value.uid)
            .collection("DayOfWeek")
            .document(dayOfWeek)
            .collection("Date")
            .document(dateFormat)
            .collection('inputs')
            .add({"Location": geoPoint, "Time": date, "InApp": true});
      }
    }));

    subscription.add(currentUserDeliveringOrdersProperty
        .bindTo(currentUserDeliveryingOrdersProducer()));

    subscription.add(currentUserDeliveredCompletedOrdersProperty
        .bindTo(currentUserDeliveredCompletedOrdersProducer()));

    subscription.add(currentUserPastWeekCanceledOrdersProperty
        .bindTo(currentUserCancelledOrders()));

    subscription.add(currentUserPastWeekCompletedOrdersProperty
        .bindTo(currentUserCompletedOrdersProducer()));

    subscription
        .add(currentUserWalletProperty.bindTo(currentUserWalletProducer()));

    // get Current Routes TODO fix bug
    subscription.add(currentUserRoutesPastDayProperty
        .bindTo(currentUserRoutesPastDayProducer()));

    subscription.add(currentPromotionsProperty.bindTo(globalPromotions()));

    subscription
        .add(currentDabaoerRewards.bindTo(currentDabaoerRewardsProducer()));

    subscription
        .add(currentDabaoeeRewards.bindTo(currentDabaoeeRewardsProducer()));

    subscription
        .add(currentUserChannelProperty.bindTo(currentUserChannelProducer()));
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Stream<List<FoodTag>> currentUserFoodTagProducer() {
    return currentUserProperty.producer.switchMap(
        (user) => user == null ? List<FoodTag>() : user.userFoodTags);
  }

  Stream<DabaoerReward> currentDabaoerRewardsProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? null
        : FirebaseCollectionReactive<DabaoerReward>(Firestore.instance
                .collection("dabaoerRewards")
                .where(DabaoerReward.validKey, isEqualTo: true)
                .orderBy(DabaoerReward.startTimeKey, descending: true)
                .limit(1))
            .observable
            .map((list) =>
                list == null ? null : list.length == 0 ? null : list.first));
  }

  Stream<DabaoeeReward> currentDabaoeeRewardsProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? null
        : FirebaseCollectionReactive<DabaoeeReward>(Firestore.instance
                .collection("dabaoeeRewards")
                .where(DabaoeeReward.validKey, isEqualTo: true)
                .orderBy(DabaoeeReward.startTimeKey, descending: true)
                .limit(1))
            .observable
            .map((list) =>
                list == null ? null : list.length == 0 ? null : list.first));
  }

  Stream<Wallet> currentUserWalletProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? null
        : Observable.just(Wallet.fromUID(user.uid)).shareReplay(maxSize: 1));
  }

  Stream<List<Order>> currentUserRequestedOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.statusKey, isEqualTo: orderStatus_Requested)
                .where(Order.creatorKey, isEqualTo: user.uid))
            .observable);
  }

  Stream<List<Channel>> currentUserChannelProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Channel>()
        : FirebaseCollectionReactive<Channel>(Firestore.instance
                .collection('channels')
                .where('P',
                    arrayContains:
                        ConfigHelper.instance.currentUserProperty.value.uid)
                .orderBy(Channel.lastSentKey, descending: true))
            .observable);
  }

  Stream<List<DabaoRoute.Route>> currentUserRoutesPastDayProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? Observable.just(List<DabaoRoute.Route>())
        : FirebaseCollectionReactive<DabaoRoute.Route>(Firestore.instance
                .collection("routes")
                .where(DabaoRoute.Route.deliveryTimeKey,
                    isGreaterThanOrEqualTo:
                        DateTime.now().add(Duration(days: -1)))
                .where(DabaoRoute.Route.creatorKey, isEqualTo: user.uid))
            .observable);
  }

  Stream<List<Order>> currentUserAcceptedOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.statusKey, isEqualTo: orderStatus_Accepted)
                .where(Order.creatorKey, isEqualTo: user.uid))
            .observable);
  }

  Stream<List<Order>> currentUserDeliveryingOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? BehaviorSubject(seedValue: List<Order>())
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.statusKey, isEqualTo: orderStatus_Accepted)
                .where(Order.delivererKey, isEqualTo: user.uid))
            .observable);
  }

  Stream<List<Order>> currentUserDeliveredCompletedOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.completedTimeKey,
                    isGreaterThanOrEqualTo:
                        DateTime.now().add(Duration(hours: -5)))
                .where(Order.statusKey, isEqualTo: orderStatus_Completed)
                .where(Order.delivererKey, isEqualTo: user.uid))
            .observable);
  }

  Stream<List<Order>> currentUserCompletedOrdersProducer() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.completedTimeKey,
                    isGreaterThanOrEqualTo:
                        DateTime.now().add(Duration(days: -7)))
                .where(Order.statusKey, isEqualTo: orderStatus_Completed)
                .where(Order.creatorKey, isEqualTo: user.uid))
            .observable);
  }

  Stream<List<Order>> currentUserCancelledOrders() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? List<Order>()
        : FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.startTimeKey,
                    isGreaterThanOrEqualTo:
                        DateTime.now().add(Duration(days: -7)))
                .where(Order.statusKey, isEqualTo: orderStatus_Cancelled)
                .where(Order.creatorKey, isEqualTo: user.uid))
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

  Observable<List<Promotion>> globalPromotions() {
    return currentUserProperty.producer.switchMap((user) => user == null
        ? Observable.just(List())
        : FirebaseCollectionReactive<Promotion>(Firestore.instance
                .collection("promotions")
                .where(Promotion.viewableKey, isEqualTo: true))
            .observable);
  }

  StreamSubscription<LatLng> location;

  void startListeningToCurrentLocation(Future<bool> askForPermission) async {
    location?.cancel();
    bool successful = await askForPermission;

    if (successful != null && successful) {
      var lastLocation =
          await LocationHelper.instance.location.getLastKnownPosition();

      if (lastLocation != null)
        currentLocationProperty.value =
            LatLng(lastLocation.latitude, lastLocation.longitude);
    }

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
