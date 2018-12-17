import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class ConfigHelper with HavingSubscriptionMixin {
  MutableProperty<User> currentUserProperty = MutableProperty<User>(null);

  MutableProperty<LatLng> currentLocationProperty =
      MutableProperty<LatLng>(null);

  MutableProperty<List<FoodTag>> currentUserFoodTagsProperty =
      MutableProperty<List<FoodTag>>(List());

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

  double deliveryFeeCalculator({int numberOfItems}) {
    print("testing 1 " + numberOfItems.toString());
    if (numberOfItems == 0) {
      return 0.0;
    } else {
    print("testing 2 " + _globalFixedPrice.value.toString());
    print("testing 3 " + (_globalFixedPrice.value + ((numberOfItems - _globalMinItemCount.value) <= 0 ? 0 :(numberOfItems - _globalMinItemCount.value))  * _globalPricePerItem.value).toString());

      return _globalFixedPrice.value + ((numberOfItems - _globalMinItemCount.value) <= 0 ? 0 :(numberOfItems - _globalMinItemCount.value))  * _globalPricePerItem.value;
    }
  }

  // Called once when app loads.
  appDidLoad() {
    disposeAndReset();

    subscription
        .add(currentUserFoodTagsProperty.bindTo(currentUserFoodTagProducer()));

    subscription.add(_globalPricePerItem.bindTo(globalConfigSettingsData()
        .map<double>((map) =>
            map.containsKey("PRICE PER ITEM") ? map["PRICE PER ITEM"] + 0.0 : 0.5)));

    subscription.add(_globalFixedPrice.bindTo(globalConfigSettingsData()
        .map<double>((map) =>
            map.containsKey("FIXED PRICE") ? map["FIXED PRICE"] +0.0 : 1.5)));

                subscription.add(_globalMinItemCount.bindTo(globalConfigSettingsData()
        .map<int>((map) =>
            map.containsKey("MIN QTY") ? map["MIN QTY"] : 2)));
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
}
