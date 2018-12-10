import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class HavingGoogleMaps {
  GoogleMapController mapController;

  Function mapCallBack;

  Future<void> panToLocation(
      GoogleMapController controller, LatLng location, double minZoom, [int delayInMilliSecs = 200]) {
        
    mapController.removeListener(mapCallBack);
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
    ).then((complete) {
      return Future.delayed(Duration(milliseconds: delayInMilliSecs), () => "1");
    }).then((s) {
      mapController.addListener(mapCallBack);
    });
  }
}
