import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/settings.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static LocationHelper get instance =>
      _internal != null ? _internal : LocationHelper();
  static LocationHelper _internal;

  Geolocator location = new Geolocator();

  Observable<LatLng> onLocationChange() {
    return Observable(location.getPositionStream())
        .where((position) => position != null)
        .map((Position result) {
      return LatLng(
        result.latitude,
        result.longitude,
      );
    });
  }

  String addressFromPlacemarker(Placemark place) {
    if (place.name.isNotEmpty) {
      var name = place.name == null || place.name.isEmpty ? '' : place.name + " ";
      var thoroughfare = place.thoroughfare == null ? '' : place.thoroughfare;
      var subThoroughfare =
          place.subThoroughfare == null || place.subThoroughfare.isEmpty ? '' : place.subThoroughfare + " ";

      if (Platform.isAndroid) {
        if (StringHelper.isNumeric(name)) {
          return name + "" + thoroughfare;
        } else {

          return name + ", " + subThoroughfare + " " + thoroughfare;
        }
      } else {
        return subThoroughfare + thoroughfare + ", " + name;
      }
    } else if (place.postalCode.isNotEmpty) {
      return place.postalCode;
    } else {
      return place.country;
    }
  }

  //Ask for permission if user denied, do nothing
  Future<bool> softAskForPermission() {
    return location
        .checkGeolocationPermissionStatus()
        .catchError((e) {})
        .then((permissionStatus) async {
      switch (permissionStatus) {
        case GeolocationStatus.granted:
          return true;

        default:
          return false;
      }
    });
  }

  //Hard ask for permission if user denied, open dialog to direct to settings
  //TODO fix issue in android whereby askForPermission does not return a future.
  Future<bool> hardAskForPermission(
      BuildContext context, Text title, Text content) {
    return location
        .checkGeolocationPermissionStatus()
        .catchError((e) {})
        .then((permissionStatus) async {
      switch (permissionStatus) {
        case GeolocationStatus.granted:
          return true;

        default:
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: title,
                  content: content,
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(
                        "DISMISS",
                        style: FontHelper.regular(Colors.black, 14.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    new FlatButton(
                      child: new Text(
                        "SETTINGS",
                        style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                      ),
                      onPressed: () async {

                        await Settings.openAppSettings();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
      }
    });
  }

  static double latitudeOffset(double latitude, double distanceInMeters) {
    var earth = 6378.137; //radius of the earth in kilometer
    var pi = math.pi;
    var m = (1 / ((2 * pi / 360) * earth)) / 1000; //1 meter in degree

    return latitude + (distanceInMeters * m);
  }

  static double longitudeOffset(
      double latitude, double longitude, double distanceInMeters) {
    var earth = 6378.137; //radius of the earth in kilometer
    var pi = math.pi;
    var cos = math.cos;
    var m = (1 / ((2 * pi / 360) * earth)) / 1000; //1 meter in degree

    return longitude + (distanceInMeters * m) / cos(latitude * (pi / 180));
  }

  static double calculateDistancFromSelf(lat1, lon1, lat2, lon2) {
    var radiusOfEarth = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(lat1)) *
            math.cos(deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = radiusOfEarth * c; // Distance in km
    return d;
  }

  static double deg2rad(deg) {
    return deg * (math.pi / 180);
  }
}
