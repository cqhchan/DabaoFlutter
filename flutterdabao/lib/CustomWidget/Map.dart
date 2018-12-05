import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';

class CustomizedMap extends StatefulWidget {
  _CustomizedMapState createState() => _CustomizedMapState();
}

class _CustomizedMapState extends State<CustomizedMap> {
  GoogleMapController mapController;

  // var currentLocation = <String, double>{};
  // var location = new Location();

  // Map<String, double> _startLocation;
  // Map<String, double> _currentLocation;

  // StreamSubscription<Map<String, double>> _locationSubscription;

  // Location _location = new Location();
  // bool _permission = false;
  // String error;

  // bool currentWidget = true;

  // Image image1;

  // @override
  // void initState() {
  //   super.initState();

  //   initPlatformState();

  //   _locationSubscription =
  //       _location.onLocationChanged().listen((Map<String, double> result) {
  //     setState(() {
  //       _currentLocation = result;
  //     });
  //   });
  // }

  // // Platform messages are asynchronous, so we initialize in an async method.
  // initPlatformState() async {
  //   Map<String, double> location;
  //   // Platform messages may fail, so we use a try/catch PlatformException.

  //   try {
  //     _permission = await _location.hasPermission();
  //     location = await _location.getLocation();

  //     error = null;
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       error = 'Permission denied';
  //     } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
  //       error =
  //           'Permission denied - please ask the user to enable it from the app settings';
  //     }

  //     location = null;
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   //if (!mounted) return;

  //   setState(() {
  //     _startLocation = location;
  //   });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   List<Widget> widgets;

  //   if (_currentLocation == null) {
  //     widgets = new List();
  //   } else {
  //     widgets = [
  //       new Image.network(
  //           "https://maps.googleapis.com/maps/api/staticmap?center=${_currentLocation["latitude"]},${_currentLocation["longitude"]}&zoom=18&size=640x400&key=AIzaSyCIIqjYS-TEsb7XziWv79Z9kEmZ-m-u2mk")
  //     ];
  //   }

  //   widgets.add(new Center(
  //       child: new Text(_startLocation != null
  //           ? 'Start location: $_startLocation\n'
  //           : 'Error: $error\n')));

  //   widgets.add(new Center(
  //       child: new Text(_currentLocation != null
  //           ? 'Continuous location: $_currentLocation\n'
  //           : 'Error: $error\n')));

  //   widgets.add(new Center(
  //       child: new Text(
  //           _permission ? 'Has permission : Yes' : "Has permission : No")));

  //   return new MaterialApp(
  //       home: new Scaffold(
  //           appBar: new AppBar(
  //             title: new Text('Location plugin example app'),
  //           ),
  //           body: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: widgets,
  //           )));
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            options: GoogleMapOptions(
              // myLocationEnabled: true,
              // cameraPosition: CameraPosition(
              //     target: LatLng(1.2923956, 103.77572039999995), zoom: 15.0),
            ),
          ),
          Align(alignment: Alignment.bottomCenter,child: FlatButton(child: Text('Add Marker'), color: Colors.blue, onPressed: mapController == null ? null : () {mapController.addMarker(MarkerOptions(position: LatLng(1.2923956, 103.77572039999995),));} ))
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();

      attributeMap["lat"] = 100;
      attributeMap["long"] = 100;
      attributeMap["radius"] = 100;

      final result = CloudFunctions.instance.call(
          functionName: 'dabaoerLocationRequest', parameters: attributeMap);
      print('Result: $result');
    } on CloudFunctionsException catch (ex) {
      print(ex);
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      mapController = controller;
    });
  }
}
