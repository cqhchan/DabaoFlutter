import 'dart:async';

import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ConfigHelper with HavingSubscriptionMixin {
  MutableProperty<User> currentUserProperty = MutableProperty<User>(null);

  MutableProperty<LatLng> currentLocationProperty =
      MutableProperty<LatLng>(null);

  String error;

  static ConfigHelper get instance =>
      _internal != null ? _internal : ConfigHelper._create();
  static ConfigHelper _internal;


  ConfigHelper._create() {
    _internal = this;
  }

  // Called once when app loads.
  appDidLoad() async{
    disposeAndReset();  
  }


  StreamSubscription<LatLng> location;

  void startListeningToCurrentLocation(Future<bool> askForPermission) async {
    location?.cancel();
    await askForPermission;
    location = currentLocationProperty.bindTo(LocationHelper.instance.onLocationChange());

  }


}
