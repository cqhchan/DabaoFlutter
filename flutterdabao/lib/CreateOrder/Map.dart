import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutterdabao/CreateOrder/LocateWidget.dart';

class Map extends StatefulWidget {
  @override
  State createState() => MapState();
}

class MapState extends State<Map> {
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
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: FlatButton(
                padding: EdgeInsets.only(top: 20.0),
                // padding: EdgeInsets.only(top: 60.0),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Image.asset('assets/icons/arrow-down-black.png'),
              ),
            ),
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
