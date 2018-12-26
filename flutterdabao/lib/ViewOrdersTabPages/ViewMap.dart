import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Buttons/CustomizedBackButton.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewMap extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ViewMap({
    Key key,
    @required this.latitude,
    @required this.longitude,
  }) : super(key: key);

  _ViewMapState createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  GoogleMapController mapController;

  @override
    void dispose() {
      // TODO: implement dispose
      mapController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Stack(
        children: <Widget>[
          Center(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              options: GoogleMapOptions(
                cameraPosition: CameraPosition(target:LatLng(widget.latitude, widget.longitude),zoom: 15 )
              ),
            ),
          ),
          CustomizedBackButton(),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    controller.addMarker(MarkerOptions(
      position:LatLng(widget.latitude, widget.longitude),
    ));
    setState(() {
      mapController = controller;
    });
  }
}
