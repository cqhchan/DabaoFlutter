// TODO:
// https://stackoverflow.com/questions/24302112/how-to-get-the-latitude-and-longitude-of-location-where-user-taps-on-the-map-in
// https://stackoverflow.com/questions/53397826/flutter-get-coordinates-from-google-maps

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';

class CustomizedMap extends StatefulWidget {
  CustomizedMap({
    Key key,
    @required this.mode,
    @required this.selectedlocation,
    this.zoom = 16,
    this.radius = 3000,
  }) : assert(mode != null);
  // Set mode to 1 to query order requests.
  // Set mode to 0 to query deliveries.
  final int mode;
  final double zoom;
  final double radius;
  final MutableProperty<LatLng> selectedlocation;

  @override
  _CustomizedMapState createState() =>
      _CustomizedMapState(mode, radius, zoom, selectedlocation);
}

class _CustomizedMapState extends State<CustomizedMap>
    with HavingSubscriptionMixin, SingleTickerProviderStateMixin {
  _CustomizedMapState(this.mode, this.radius, this.zoom, this.selectedlocation);

  int mode;
  double zoom;
  double radius;
  String error;
  Location location = new Location();
  GoogleMapController mapController;
  Marker _selectedMarker;
  Map<String, double> _currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;
  MutableProperty<LatLng> selectedlocation;
  MutableProperty<List<LatLng>> markerLocations = MutableProperty(List());
  MutableProperty<LatLng> updateMarkerLocation = MutableProperty(null);
  MutableProperty<LatLng> currentLocation = MutableProperty(null);
  MutableProperty<LatLng> tapLocation = MutableProperty(null);

  Future<void> fetchJSON(LatLng thislocation) async {
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["lat"] = thislocation.latitude;
      attributeMap["long"] = thislocation.longitude;
      attributeMap["radius"] = radius;
      attributeMap["mode"] = mode;
      final result = await CloudFunctions.instance
          .call(functionName: 'locationRequest', parameters: attributeMap);
      List<LatLng> temp = List();
      result['locations'].forEach((latlng) {
        double latitude = latlng[0];
        double longitude = latlng[1];
        temp.add(LatLng(latitude, longitude));
      });
      markerLocations.producer.add(temp);
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize for iOS only
    _currentLocation['latitude'] = 1.2923956;
    _currentLocation['longitude'] = 103.7757203999999;

    initGoogleMap();

    subscription.add(markerLocations.producer.listen((_) {}));
    subscription.add(currentLocation.producer.listen((_) {}));
    subscription.add(tapLocation.producer.listen((_) {}));
    subscription.add(updateMarkerLocation.producer.listen((_) {}));
    subscription.add(selectedlocation.producer.listen((_) {}));

    selectedlocation.producer.take(1).listen((result) {
      print('Selected Location at CustomizedMap.dart: $result');
    });

    // User's Device Location
    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      currentLocation.producer.add(
        // Default location to NUS for Testing Purposes
        // LatLng(1.2923956, 103.7757203999999),
        LatLng(
          result["latitude"],
          result["longitude"],
        ),
      );
      print(
          "Current User's Location ------ Lat: ${result["latitude"]} ------ Lng: ${result["longitude"]}");
      setState(() {
        _currentLocation = result;
      });
    });
  }

  void initGoogleMap() async {
    currentLocation.producer.listen((value) {
      _currentLocation['latitude'] = value.latitude;
      _currentLocation['longitude'] = value.longitude;
    });

    // Request permission
    initPlatformState();
  }

  void initPlatformState() async {
    try {
      await location.hasPermission();
      error = null;
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        error = 'Permission denied';
      } else if (e.code == "PERMISSION_DENIED_NEVER_ASK") {
        error =
            'Permission denied - please ask the user to enable it from the app setting';
      }
      print(error);
    }
  }

  void _onMarkerTapped(Marker marker) {
    setState(() {
      _selectedMarker = marker;
    });
    print('Selected Location: ${_selectedMarker.options.position}');
  }

  void _panToCurrentLocation(GoogleMapController controller, LatLng result) {
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: zoom,
          target: LatLng(
            result.latitude,
            result.longitude,
          ),
        ),
      ),
    );
  }

  void _createDraggableMarker(GoogleMapController controller) {
    currentLocation.producer.take(1).listen((result) {
      controller.addMarker(MarkerOptions(
        infoWindowText: InfoWindowText('To Dabaoer:', 'Let Meet Here!'),
        draggable: true,
        position: result,
      ));
    });
    setState(() {
      mapController = controller;
    });
  }

  void _updateDraggableMarker(GoogleMapController controller) {
    selectedlocation.producer.listen((result) {
      controller.clearMarkers();
      controller.addMarker(MarkerOptions(
        infoWindowText: InfoWindowText('To Dabaoer:', 'Let Meet Here!'),
        draggable: true,
        position: LatLng(result.latitude, result.longitude),
      ));
      _panToCurrentLocation(controller, result);
      // fetchJSON(result);
    });
    setState(() {
      mapController = controller;
    });
  }

  void _createMarkers() {
    markerLocations.producer.value.forEach((location) {
      mapController.addMarker(MarkerOptions(
          icon: BitmapDescriptor.fromAsset('assets/icons/bike.png'),
          draggable: false,
          infoWindowText: InfoWindowText('From Dabaoer:', "Good Food!"),
          position: location));
    });
  }

  void _initBeforeFetchJSON() {
    LatLng temp = new LatLng(
      _currentLocation['latitude'],
      _currentLocation['longitude'],
    );
    currentLocation.producer.add(temp);
    currentLocation.producer.listen((thisLocation) {
      if (thisLocation != null) {
        // fetchJSON(thisLocation);
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _initBeforeFetchJSON();
    _createDraggableMarker(controller);
    _updateDraggableMarker(controller);
    controller.onMarkerTapped.add(_onMarkerTapped);
    setState(() {
      mapController = controller;
    });
  }

  @override
  void dispose() {
    mapController?.onMarkerTapped?.remove(_onMarkerTapped);
    locationSubscription.pause();
    subscription.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
          child: StreamBuilder(
              stream: markerLocations.producer,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  case ConnectionState.none:
                  case ConnectionState.active:
                    _createMarkers();
                    return updateMap;
                  case ConnectionState.done:
                }
              }),
        ),
    );
  }

  Widget get updateMap {
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
                target: LatLng(
                  _currentLocation['latitude'],
                  _currentLocation['longitude'],
                ),
                zoom: zoom,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
