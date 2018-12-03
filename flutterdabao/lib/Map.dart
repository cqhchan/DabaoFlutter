import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutterdabao/CreateOrder/LocateWidget.dart';

class MapsDemo extends StatefulWidget {
  @override
  State createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo> {
  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     mapController.animateCamera(CameraUpdate.newCameraPosition(
      //       const CameraPosition(
      //         bearing: 270.0,
      //         target: LatLng(51.5160895, -0.1294527),
      //         tilt: 30.0,
      //         zoom: 17.0,
      //       ),
      //     ));
      //   },
      // ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                ),
              ),
            ],
          ),
          LocateWidget(),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
