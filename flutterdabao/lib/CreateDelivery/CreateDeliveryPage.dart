// import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:map_view/map_options.dart';
// import 'package:flutterdabao/CreateDelivery/Favorite.dart';
// import 'package:flutterdabao/CreateDelivery/CompositeSubcription.dart';
// import 'package:flutterdabao/CreateDelivery/FavoriteListWidget.dart';
// import 'package:flutterdabao/CreateDelivery/FavoritesManager.dart';
// import 'package:flutterdabao/CreateDelivery/StaticLocation.dart';

import 'package:map_view/map_view.dart';
// import 'package:google_maps_webservice/places.dart' as places;

var api_key =
    "AIzaSyA1VBJqZV92zUzMmNUrrq2oZpDKo_ckk2o"; //iOS Google Map API KEY only

//import 'package:flutterdabao/containers/date_time_section.dart';

class Delivery extends StatefulWidget {
  _DeliveryState createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  MapView mapView = new MapView();
  CameraPosition cameraPosition;
  var staticMapProvider = new StaticMapProvider(api_key);
  Uri staticMapUri;

  List<Marker> markers = <Marker>[
    new Marker("1", "BSR Restuarant", 28.421364, 77.333804,
        color: Colors.amber),
    new Marker("2", "Flutter Institute", 28.418684, 77.340417,
        color: Colors.purple),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cameraPosition =
        new CameraPosition(new Location(28.420035, 77.337628), 2.0);
    staticMapUri = staticMapProvider.getStaticUri(
        new Location(28.420035, 77.337628), 12,
        height: 400, width: 900, mapType: StaticMapViewType.roadmap);
  }

  showMap() {
    mapView.show(MapOptions(
        mapViewType: MapViewType.normal,
        initialCameraPosition:
            CameraPosition(Location(28.420035, 77.337628), 15.0),
        showUserLocation: true,
        title: "Recent Location"));
    mapView.setMarkers(markers);
    mapView.zoomToFit(padding: 100);

    mapView.onMapReady.listen((_) {
      setState(() {
        mapView.setMarkers(markers);
        mapView.zoomToFit(padding: 100);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Flutter Google maps"),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            height: 300.0,
            child: new Stack(
              children: <Widget>[
                new Center(
                  child: Container(
                    child: new Text(
                      "Map should show here",
                      textAlign: TextAlign.center,
                    ),
                    padding: const EdgeInsets.all(20.0),
                  ),
                ),
                new InkWell(
                  child: new Center(
                    child: new Image.network(staticMapUri.toString()),
                  ),
                  onTap: showMap,
                )
              ],
            ),
          ),
          new Container(
            padding: new EdgeInsets.only(top: 10.0),
            child: new Text(
              "Tap the map to interact",
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          new Container(
            padding: new EdgeInsets.only(top: 25.0),
            child: new Text(
                "Camera Position: \n\nLat: ${cameraPosition.center.latitude}\n\nLng:${cameraPosition.center.longitude}\n\nZoom: ${cameraPosition.zoom}"),
          ),
        ],
      ),
    );
  }
}

