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
  _CustomizedMapState createState() => _CustomizedMapState();
}

class _CustomizedMapState extends State<CustomizedMap>
    with HavingSubscriptionMixin, SingleTickerProviderStateMixin {
  GoogleMapController mapController;
  Marker _selectedMarker;

  // Map<String, double> _startLocation = new Map();
  Map<String, double> _currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  Location location = new Location();
  String error;

  // static LatLng locationProp = new LatLng(1.2923956, 103.77572039999995);
  // MutableProperty<LatLng> currentLocation = MutableProperty(locationProp);
  // MutableProperty<LatLng> currentLocation = ConfigHelper.instance.currentLocationProperty;
  MutableProperty<LatLng> oneTimeLocation = MutableProperty(null);
  MutableProperty<LatLng> currentLocation = MutableProperty(null);
  MutableProperty<LatLng> tapLocation = MutableProperty(null);
  MutableProperty<List<LatLng>> markerLocations = MutableProperty(List());

  Future<void> fetchJSON(LatLng thislocation) async {
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();

      attributeMap["lat"] = thislocation.latitude;
      attributeMap["long"] = thislocation.longitude;

      // the radius is 3km
      attributeMap["radius"] = 3000;

      // 0 = deliveries
      // 1 = requests
      attributeMap["mode"] = 0;

      final result = await CloudFunctions.instance
          .call(functionName: 'locationRequest', parameters: attributeMap);

      List<LatLng> temp = List();
      result['locations'].forEach((latlng) {
        double latitude = latlng[0];
        double longitude = latlng[1];

        temp.add(LatLng(latitude, longitude));
      });

      // Add location of markers to stream
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
    initGoogleMap();

    subscription.add(markerLocations.producer.listen((_) {}));
    subscription.add(currentLocation.producer.listen((_) {}));
    subscription.add(tapLocation.producer.listen((_){}));

    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      oneTimeLocation.producer.add(
        LatLng(1.2923956, 103.7757203999999),
      );
      currentLocation.producer.add(
        // Default location to NUS for Testing Purposes
        LatLng(1.2923956, 103.7757203999999),
        // LatLng(
        //   result["latitude"],
        //   result["longitude"],
        // ),
      );
      print("Current User's Location ------ Lat: ${result["latitude"]} Lng: ${result["longitude"]}");
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

  void _panToCurrentLocation(GoogleMapController controller) {
    currentLocation.producer.listen((result) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 16,
            target: LatLng(
              result.latitude,
              result.longitude,
            ),
          ),
        ),
      );
    });
  }

  void _createDraggableMarker(GoogleMapController controller) {
    oneTimeLocation.producer.take(1).listen((result) {
      controller.addMarker(MarkerOptions(
        infoWindowText: InfoWindowText('To Dabaoer:', 'Let Meet Here!'),
        draggable: true,
        position: result,
      ));
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

  void _onMapCreated(GoogleMapController controller) {
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

    _panToCurrentLocation(controller);

    _createDraggableMarker(controller);

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
                    // Create Deliveries or Requests Markers
                    _createMarkers();
                    // Update Google Map
                    return updateMap;
                  case ConnectionState.done:
                }
              }),
        ),
    );
  }

  // Google Map Widget
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
                  zoom: 15),
            ),
          ),
          // Align(
          //   alignment: Alignment.topRight,
          //   child: Container(
          //     padding: EdgeInsets.only(top: 10.0),
          //     child: IconButton(
          //       icon: Icon(
          //         Icons.my_location,
          //         color: ColorHelper.dabaoOffBlack4A,
          //       ),
          //       onPressed: mapController == null
          //           ? null
          //           : () {
          //               _panCameraPostitionToCurrentLocation(mapController);
          //             },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
