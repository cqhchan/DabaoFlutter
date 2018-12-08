import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:flutter/services.dart';
// import 'package:rxdart/rxdart.dart';

class ConfigHelper with HavingSubscriptionMixin {
  MutableProperty<User> currentUserProperty = MutableProperty<User>(null);

  MutableProperty<LatLng> currentLocationProperty =
      MutableProperty<LatLng>(null);

  String error;

  static ConfigHelper get instance =>
      _internal != null ? _internal : ConfigHelper._create();
  static ConfigHelper _internal;

  // Location location = new Location();

  ConfigHelper._create() {
    _internal = this;
  }

  // Called once when app loads.
  appDidLoad() {
    disposeAndReset();

    // askForPermission();

    // location.onLocationChanged().listen((Map<String, double> result) {
    //   setState(() {
    //     _currentLocation = result;
    //   });
    // });

    // subscription.add(currentLocationProperty.producer.listen((_) {
    //   print('Listening...');
    // }));

    // location.onLocationChanged().map((Map<String, double> location) {
    //   currentLocationProperty.producer
    //       .add(LatLng(location['latitude'], location['longitude']));
    // }).listen((_){print('Listened...');});

    // subscription.add(currentLocationProperty
    //     .bindTo(Observable(location.onLocationChanged()).map((value) =>
    //    LatLng(value['latitude'], value['longitude']))));

    // subscription.add(allLocationsProperty.bindTo(allLocationProducer()));
  }

  // askForPermission() async {
  //   try {
  //     await location.hasPermission();
  //     await location.getLocation();
  //   } on PlatformException catch (e) {
  //     if (e.code == "PERMISSION_DENIED") {
  //       error = 'Permission denied';
  //     } else if (e.code == "PERMISSION_DENIED_NEVER_ASK") {
  //       error =
  //           'Permission denied - please ask the user to enable it from the app setting';
  //     }
  //   }
  // }
}
