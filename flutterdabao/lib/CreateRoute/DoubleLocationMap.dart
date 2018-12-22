// TODO:
// https://stackoverflow.com/questions/24302112/how-to-get-the-latitude-and-longitude-of-location-where-user-taps-on-the-map-in
// https://stackoverflow.com/questions/53397826/flutter-get-coordinates-from-google-maps

import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMaps.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';

class DoubleLocationCustomizedMap extends StatefulWidget {
  DoubleLocationCustomizedMap({
    Key key,
    @required this.startSelectedLocation,
    @required this.startSelectedLocationDescription,
    @required this.endSelectedLocation,
    @required this.endSelectedLocationDescription,
    @required this.focusOnStart,
    this.zoom = 16,
    this.radius = 3000,
  });

  final double zoom;
  final double radius;
  final MutableProperty<LatLng> startSelectedLocation;
  final MutableProperty<String> startSelectedLocationDescription;
  final MutableProperty<LatLng> endSelectedLocation;
  final MutableProperty<String> endSelectedLocationDescription;
  final MutableProperty<bool> focusOnStart;

  @override
  _DoubleLocationCustomizedMapState createState() =>
      _DoubleLocationCustomizedMapState();
}

class _DoubleLocationCustomizedMapState
    extends State<DoubleLocationCustomizedMap>
    with
        HavingSubscriptionMixin,
        SingleTickerProviderStateMixin,
        HavingGoogleMaps {
  _DoubleLocationCustomizedMapState();

  //TODO Locations of people who are ordering nearby
  // MutableProperty<List<LatLng>> markerLocations = MutableProperty(List());

  // Current User Location
  MutableProperty<LatLng> currentLocation =
      ConfigHelper.instance.currentLocationProperty;

  MutableProperty<LatLng> get focusedSelectedLocation =>
      widget.focusOnStart.value
          ? widget.startSelectedLocation
          : widget.endSelectedLocation;

  MutableProperty<String> get focusedSelectedLocationDescription =>
      widget.focusOnStart.value
          ? widget.startSelectedLocationDescription
          : widget.endSelectedLocationDescription;

  Marker get focusedMarker =>
      widget.focusOnStart.value ? _startDeliveryMarker : _endDeliveryMarker;

  // Delivery Marker
  Marker _startDeliveryMarker;
  Marker _endDeliveryMarker;

  //Delivery Icon when stationary
  BitmapDescriptor get startIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset('assets/icons/blue_pin.png');
    else
      return BitmapDescriptor.fromAsset('assets/icons/3.0x/blue_pin.png');
  }

  //Delivery Icon when Moving
  BitmapDescriptor get lightStartIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset('assets/icons/blue_pin_light.png');
    else
      return BitmapDescriptor.fromAsset('assets/icons/3.0x/blue_pin_light.png');
  }

  //Delivery Icon when stationary
  BitmapDescriptor get endIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset('assets/icons/red_pin.png');
    else
      return BitmapDescriptor.fromAsset('assets/icons/3.0x/red_pin.png');
  }

  //Delivery Icon when Moving
  BitmapDescriptor get lightEndIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset('assets/icons/red_pin_light.png');
    else
      return BitmapDescriptor.fromAsset('assets/icons/3.0x/red_pin_light.png');
  }

  bool lastCameraIsMoving = false;
  LatLng lastLatLng;

  @override
  void initState() {
    super.initState();

    // Request permission and start listening to current location
    startListeningToCurrentLocation();
  }

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
                // if there is no start/currentLocation it will show NUS location
                target: widget.startSelectedLocation.value == null
                    ? LatLng(1.2966, 103.7764)
                    : widget.startSelectedLocation.value,
                zoom: widget.zoom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //let address from selected LatLng and update the selected Location and Selected Locaition Description
  //Used when used moves the map
  void updateSelectedLocationFromLatLng(LatLng location) async {
    List<Placemark> addresses = await LocationHelper.instance.location
        .placemarkFromCoordinates(location.latitude, location.longitude);
    Placemark first = addresses.first;

    focusedSelectedLocationDescription.value =
        LocationHelper.instance.addressFromPlacemarker(first);
    focusedSelectedLocation.value = location;
  }

  //Ask for permission and start listening to current location
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
    subscription
        .add(widget.startSelectedLocation.producer.listen((result) async {
      if (_startDeliveryMarker == null) {
        Marker tempMarker = await controller.addMarker(MarkerOptions(
          icon: startIcon,
          infoWindowText: InfoWindowText('Buying From', ""),
          draggable: false,
          consumeTapEvents: false,
          position: result,
        ));

        if (_startDeliveryMarker == null) {
          _startDeliveryMarker = tempMarker;
        } else {
          controller.removeMarker(tempMarker);
        }
      } else {
        await controller.updateMarker(
            _startDeliveryMarker,
            MarkerOptions(
              icon: startIcon,
              position: result,
            ));
      }
    }));

    subscription.add(widget.endSelectedLocation.producer.listen((result) async {
      if (_endDeliveryMarker == null) {
        Marker tempMarker = await controller.addMarker(MarkerOptions(
          icon: endIcon,
          infoWindowText: InfoWindowText('Delivering To', ""),
          draggable: false,
          consumeTapEvents: false,
          position: result,
        ));

        if (_endDeliveryMarker == null) {
          _endDeliveryMarker = tempMarker;
        } else {
          controller.removeMarker(tempMarker);
        }
      } else {
        await controller.updateMarker(
            _endDeliveryMarker,
            MarkerOptions(
              icon: endIcon,
              position: result,
            ));
      }
    }));

    subscription.add(widget.focusOnStart.producer
        .switchMap((focusOnStart) => focusOnStart
            ? widget.startSelectedLocation.producer
            : widget.endSelectedLocation.producer)
        .listen((location) {
      panToLocation(controller, location, widget.zoom);
    }));
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

// Whtt do do when Map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _createDeliveryMarker(mapController);

    controller.addListener(mapCallBack);

    controller.onMarkerTapped.add((marker) {
      if (marker == _startDeliveryMarker) {
        widget.focusOnStart.value = true;
      }

      if (marker == _endDeliveryMarker) {
        widget.focusOnStart.value = false;
      }
    });

    subscription.add(currentLocation.producer
        .where((latlng) => latlng != null)
        .listen((location) {
      if (widget.startSelectedLocation.value == null ||
          widget.startSelectedLocationDescription.value == null) {
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

  //Set the Map Callback Function
  // called when map is moving/ stopped moving
  @override
  mapCallBack() async {
    if (mapController.isCameraMoving) {
      if (focusedMarker != null &&
          mapController.cameraPosition.target != lastLatLng) {
        if (lastCameraIsMoving) {
          //Update Location
          print("Update Location");
          mapController.updateMarker(
              focusedMarker,
              MarkerOptions(
                position: mapController.cameraPosition.target,
              ));
        } else {
          if (focusedMarker == _startDeliveryMarker)
            await mapController.updateMarker(
                focusedMarker,
                MarkerOptions(
                  icon: lightStartIcon,
                  // position: mapController.cameraPosition.target,
                ));
          else
            await mapController.updateMarker(
                focusedMarker,
                MarkerOptions(
                  icon: lightEndIcon,
                  // position: mapController.cameraPosition.target,
                ));
          lastCameraIsMoving = true;
        }
      }
      lastLatLng = mapController.cameraPosition.target;
    } else {
      if (lastCameraIsMoving) {
        updateSelectedLocationFromLatLng(mapController.cameraPosition.target);
      }
      lastCameraIsMoving = false;
    }
  }
}
