import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMaps.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';

class CustomizedMap extends StatefulWidget {
  CustomizedMap({
    Key key,
    @required this.selectedlocation,
    @required this.selectedlocationDescription,
    this.zoom = 16,
    this.radius = 3000,
  });

  final double zoom;
  final double radius;
  final MutableProperty<LatLng> selectedlocation;
  final MutableProperty<String> selectedlocationDescription;

  @override
  _CustomizedMapState createState() => _CustomizedMapState(
      radius, zoom, selectedlocation, selectedlocationDescription);
}

class _CustomizedMapState extends State<CustomizedMap>
    with
        HavingSubscriptionMixin,
        SingleTickerProviderStateMixin,
        HavingGoogleMaps {
  _CustomizedMapState( this.radius, this.zoom, this.selectedlocation,
      this.selectedlocationDescription);

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

  // Delivery Marker
  Marker _deliveryMarker;

  //Delivery Icon when stationary
  BitmapDescriptor get deliveryIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset('assets/icons/orange_pin.png');
    else
      return BitmapDescriptor.fromAsset(
          'assets/icons/3.0x/orange_pin.png');
  }

  //Delivery Icon when Moving
  BitmapDescriptor get semiOpaqueDeliveryIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset(
          'assets/icons/orange_pin_light.png');
    else
      return BitmapDescriptor.fromAsset(
          'assets/icons/3.0x/orange_pin_light.png');
  }

  //bikeIcon of nearby Dabaoers
  BitmapDescriptor get bikeIcon {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS)
      return BitmapDescriptor.fromAsset('assets/icons/bike.png');
    else
      return BitmapDescriptor.fromAsset('assets/icons/3.0x/bike.png');
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
    return Center(
        child: createMap,
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

  //let address from selected LatLng and update the selected Location and Selected Locaition Description
  //Used when used moves the map
  void updateSelectedLocationFromLatLng(LatLng location) async {
    List<Placemark> addresses = await LocationHelper.instance.location
        .placemarkFromCoordinates(location.latitude, location.longitude);
    Placemark first = addresses.first;

    selectedlocationDescription.value =
        LocationHelper.instance.addressFromPlacemarker(first);
    selectedlocation.value = location;
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
    subscription.add(selectedlocation.producer.listen((result) async {
      if (_deliveryMarker == null) {
        Marker tempMarker = await controller.addMarker(MarkerOptions(
          icon: deliveryIcon,
          infoWindowText: InfoWindowText('Delivery Location', ''),
          draggable: false,
          consumeTapEvents: false,
          position: result,
        ));

        if (_deliveryMarker == null) {
          _deliveryMarker = tempMarker;
        } else {
          controller.removeMarker(tempMarker);
        }
      } else {
        await controller.updateMarker(
            _deliveryMarker,
            MarkerOptions(
              icon: deliveryIcon,
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

//Create nearby Markers of Dabaoers
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
        FirebaseCloudFunctions
            .fetchNearbyDeliveries(location: location)
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

// Whtt do do when Map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _createDeliveryMarker(mapController);
    _createNearbyMarkers(mapController);

    controller.addListener(mapCallBack);
    isCallBackAdded = true;
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

  //Set the Map Callback Function
  // called when map is moving/ stopped moving
  @override
  mapCallBack() async {

    if (mapController.isCameraMoving) {
      
        if (_deliveryMarker != null && mapController.cameraPosition.target != lastLatLng ) {
        
        if (lastCameraIsMoving) {
          //Update Location
          mapController.updateMarker(
              _deliveryMarker,
              MarkerOptions(
                position: mapController.cameraPosition.target,
              ));
        } else {
          //Update Image
          await mapController.updateMarker(
              _deliveryMarker,
              MarkerOptions(
                icon: semiOpaqueDeliveryIcon,
                position: mapController.cameraPosition.target,
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
