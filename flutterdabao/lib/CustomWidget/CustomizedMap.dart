import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    with HavingSubscriptionMixin {
  GoogleMapController mapController;

  Map<String, double> _startLocation = new Map();
  Map<String, double> _currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  Location location = new Location();
  String error;
  bool _permission = false;

  // Default Location to NUS if permission is not granted
  static LatLng locationProp = new LatLng(1.2923956, 103.77572039999995);
  MutableProperty<LatLng> currentLocation = MutableProperty(locationProp);
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

    // Request permission
    initPlatformState();

    subscription.add(markerLocations.producer.listen((_) {
      print('Listening...');
    }));

    subscription.add(currentLocation.producer.listen((_) {
      print('Listening');
    }));

    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        _currentLocation = result;
      });
    });
  }

  void initPlatformState() async {
    Map<String, double> my_location;
    try {
      _permission = await location.hasPermission();
      my_location = await location.getLocation();
      error = null;
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        error = 'Permission denied';
      } else if (e.code == "PERMISSION_DENIED_NEVER_ASK") {
        error =
            'Permission denied - please ask the user to enable it from the app setting';
      }
      my_location = null;
    }
    setState(() {
      _startLocation = my_location;
    });
  }

  void _createCurrentLocationMarker() {
    currentLocation.producer.listen((value) {
      mapController.addMarker(MarkerOptions(
        position: LatLng(value.latitude, value.longitude),
      ));
    });
  }

  void _createMarkers() {
    markerLocations.producer.value.forEach((location) {
      mapController.addMarker(MarkerOptions(
          icon: BitmapDescriptor.fromAsset('assets/icons/bike.png'),
          draggable: false,
          position: location));
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    // Add current location of user to stream
    LatLng defaultTest = locationProp;
    LatLng temp =
        new LatLng(_currentLocation['latitude'], _currentLocation['longitude']);
    currentLocation.producer.add(temp);
    currentLocation.producer.listen((thisLocation) {
      if (thisLocation != null) {
        fetchJSON(thisLocation);
      }
    });
    setState(() {
      mapController = controller;
    });
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    subscription.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Scaffold(
          body: StreamBuilder(
              stream: markerLocations.producer,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  case ConnectionState.none:
                    return LinearProgressIndicator();
                  case ConnectionState.active:
                    // Create Deliveries or Requests Markers
                    _createMarkers();
                    // Create Current Location Marker
                    _createCurrentLocationMarker();
                    // Update Google Map
                    return updatedMap;
                  case ConnectionState.done:
                }
              }),
        ),
      ),
    );
  }

  // Google Map Widget
  Widget get updatedMap {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            options: GoogleMapOptions(
              cameraPosition: CameraPosition(
                  target: LatLng(_currentLocation['latitude'],
                      _currentLocation['longitude']),
                  zoom: 15.0),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.only(top: 30.0),
              child: IconButton(
                icon: Icon(Icons.my_location),
                onPressed: mapController == null
                    ? null
                    : () {
                        mapController.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(
                                zoom: 15,
                                target: LatLng(_currentLocation['latitude'],
                                    _currentLocation['longitude']))));
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
