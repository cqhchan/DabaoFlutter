import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

launchMaps(LatLng location) async {
  print(location.latitude);
  print(location.latitude);

  String googleUrl =
      'comgooglemaps://?center=${location.latitude},${location.longitude}';
  String appleUrl =
      'https://maps.apple.com/?q=${location.latitude},${location.longitude}';
  if (Platform.isIOS) {
    if (await canLaunch(appleUrl)) {
      print('launching apple url');
      await launch(appleUrl);
    } else {
      throw 'Could not launch url';
    }
  } else {
    if (await canLaunch("comgooglemaps://")) {
      print('launching com googleUrl');
      await launch(googleUrl);
    } else {
      throw 'Could not launch url';
    }
  }
}

abstract class HavingGoogleMaps {
  GoogleMapController mapController;
  bool isCallBackAdded = true;
  mapCallBack();

  Future<void> panToLocation(
      GoogleMapController controller, LatLng location, double minZoom,
      [int delayInMilliSecs = 500]) {
    mapController.removeListener(mapCallBack);
    isCallBackAdded = false;

    return controller
        .moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              location.latitude,
              location.longitude,
            ),
            zoom: controller.cameraPosition.zoom > minZoom
                ? controller.cameraPosition.zoom
                : minZoom),
      ),
    )
        .then((complete) {
      return Future.delayed(
          Duration(milliseconds: delayInMilliSecs), () => "1");
    }).then((s) {
      if (!isCallBackAdded) {
        mapController.addListener(mapCallBack);
        isCallBackAdded = true;
      }
    });
  }
}
