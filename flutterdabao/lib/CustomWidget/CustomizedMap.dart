// TODO:
// https://stackoverflow.com/questions/24302112/how-to-get-the-latitude-and-longitude-of-location-where-user-taps-on-the-map-in
// https://stackoverflow.com/questions/53397826/flutter-get-coordinates-from-google-maps

import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMaps.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';

class CustomizedMap extends StatefulWidget {
  CustomizedMap({
    Key key,
    @required this.mode,
    @required this.selectedlocation,
    @required this.selectedlocationDescription,
    this.zoom = 16,
    this.radius = 3000,
  }) : assert(mode != null);
  // Set mode to 1 to query order requests.
  // Set mode to 0 to query deliveries.
  final int mode;
  final double zoom;
  final double radius;
  final MutableProperty<LatLng> selectedlocation;
  final MutableProperty<String> selectedlocationDescription;

  @override
  _CustomizedMapState createState() => _CustomizedMapState(
      mode, radius, zoom, selectedlocation, selectedlocationDescription);
}

class _CustomizedMapState extends State<CustomizedMap>
    with
        HavingSubscriptionMixin,
        SingleTickerProviderStateMixin,
        HavingGoogleMaps {
  _CustomizedMapState(this.mode, this.radius, this.zoom, this.selectedlocation,
      this.selectedlocationDescription);

  int mode;
  double zoom;
  double radius;

  // Order delivery location
  MutableProperty<LatLng> selectedlocation;

  // Order delivery location
  MutableProperty<String> selectedlocationDescription;

  // Locations of people who are delivering nearby
  MutableProperty<List<LatLng>> markerLocations = MutableProperty(List());

  // Current User Location
  MutableProperty<LatLng> currentLocation =
      ConfigHelper.instance.currentLocationProperty;

  Marker _deliveryMarker;

  BitmapDescriptor get deliveryIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset('assets/icons/red_marker_icon.png');
    else
      return BitmapDescriptor.fromAsset(
          'assets/icons/3.0x/red_marker_icon.png');
  }

  BitmapDescriptor get bikeIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset('assets/icons/bike.png');
    else
      return BitmapDescriptor.fromAsset('assets/icons/3.0x/bike.png');
  }

  @override
  void initState() {
    super.initState();

    // Request permission and start listening to current location
    startListeningToCurrentLocation();

    // When it first loads, if selected location/ selected location desription is null, it will set them to current location

    mapCallBack = () {
      if (mapController.isCameraMoving) {
        {
          if (_deliveryMarker != null)
            mapController.updateMarker(
                _deliveryMarker,
                MarkerOptions(
                  position: mapController.cameraPosition.target,
                ));
        }

        lastCameraIsMoving = true;
      } else {
        if (lastCameraIsMoving) {
          updateSelectedLocationFromLatLng(mapController.cameraPosition.target);
        }
        lastCameraIsMoving = false;
      }
    };
  }

  void updateSelectedLocationFromLatLng(LatLng location) async {
    List<Placemark> addresses = await LocationHelper.instance.location
        .placemarkFromCoordinates(location.latitude, location.longitude);
    Placemark first = addresses.first;

    selectedlocationDescription.value =
        LocationHelper.instance.addressFromPlacemarker(first);
    selectedlocation.value = location;
  }

  void startListeningToCurrentLocation() async {
    ConfigHelper.instance.startListeningToCurrentLocation(
        LocationHelper.instance.hardAskForPermission(
            context,
            Text("Please Enable Location"),
            Text(
                "Dabao needs your location to verify your Orders/Deliveries")));
  }

// Create marker, updates if nesscery when selectedLocation is updated
  void _createDeliveryMarker(GoogleMapController controller) {
    subscription.add(selectedlocation.producer.listen((result) async {
      if (_deliveryMarker == null) {
        _deliveryMarker = await controller.addMarker(MarkerOptions(
          icon: deliveryIcon,
          infoWindowText: InfoWindowText('Delivery Location', 'Hold to Drag'),
          draggable: true,
          consumeTapEvents: false,
          position: result,
        ));
      } else {
        await controller.updateMarker(
            _deliveryMarker,
            MarkerOptions(
              position: result,
            ));
      }
      panToLocation(controller, result, zoom);
    }));
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  void _createNearbyMarkers(GoogleMapController controller) {
    LatLng previousLatLng;

    // if previous locatiion to current location is > 2000, search again
    subscription.add(selectedlocation.producer.listen((location) async {
      if (previousLatLng != null) {
        double distance = await LocationHelper.instance.location
            .distanceBetween(location.latitude, location.longitude,
                previousLatLng.latitude, previousLatLng.longitude);
        if (distance < 2000) {
          return;
        }
      }
      previousLatLng = location;

      //If Debug Mode, dont query
      if (!isInDebugMode)
      FirebaseCloudFunctions()
          .fetchNearbyOrderOrDeliveries(location: location, mode: 0)
          .then((list) {
        markerLocations.value = list;
      });
    }));

    subscription.add(markerLocations.producer.listen((markerLocations) {
      markerLocations.forEach((location) {
        mapController.addMarker(MarkerOptions(
            icon: bikeIcon,
            draggable: false,
            infoWindowText: InfoWindowText('Dabaoer', "Good Food!"),
            position: location));
      });
    }));
  }

  bool lastCameraIsMoving = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _createDeliveryMarker(mapController);
    _createNearbyMarkers(mapController);

    controller.addListener(mapCallBack);

    subscription.add(currentLocation.producer
        .where((latlng) => latlng != null)
        .listen((location) {
      if (selectedlocation.value == null ||
          selectedlocationDescription.value == null) {
        updateSelectedLocationFromLatLng(location);
      }
    }));
  }

  @override
  void dispose() {
    subscription.dispose();
    mapController.dispose();
    super.dispose();
  }

// currentLocation
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: createMap,
      ),
    );
  }

  Widget get createMap {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            options: GoogleMapOptions(
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              compassEnabled: false,
              trackCameraPosition: true,
              myLocationEnabled: true,
              cameraPosition: CameraPosition(
                // if there is no selectedLocation it will show NUS location
                target: selectedlocation.value == null
                    ? LatLng(1.2966, 103.7764)
                    : selectedlocation.value,
                zoom: zoom,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
