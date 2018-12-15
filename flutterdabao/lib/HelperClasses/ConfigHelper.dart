import 'dart:async';

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

  String error;

  static ConfigHelper get instance =>
      _internal != null ? _internal : ConfigHelper._create();
  static ConfigHelper _internal;

  ConfigHelper._create() {
    _internal = this;
  }

  // Called once when app loads.
  appDidLoad() async {
    disposeAndReset();

    subscription.add(currentUserFoodTagsProperty.bindTo(currentUserFoodTagProducer()));
  }

  Observable<List<FoodTag>> currentUserFoodTagProducer() {
    return currentUserProperty.producer.switchMap(
        (user) => user == null ? List<FoodTag>() : user.userFoodTags);
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
