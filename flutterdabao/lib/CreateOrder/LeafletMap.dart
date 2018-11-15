import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
// import 'package:flutterdabao/CreateDelivery/StaticLocation.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class LeafletMap extends StatefulWidget {
  _LeafletMapState createState() => _LeafletMapState();
}

class _LeafletMapState extends State<LeafletMap> {
  @override
  Widget build(BuildContext context) {
    return new FlutterMap(
      options: new MapOptions(
          center: new LatLng(1.2923956, 103.77572039999995),
          maxZoom: 20.0,
          minZoom: 15.0),
      layers: [
        new TileLayerOptions(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/chris92/cjoe5fg9o00482smskg6a66mu/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1IjoiY2hyaXM5MiIsImEiOiJjam9lNjM4dTgxdWI0M3BsZXNsZW8wNTlwIn0.3YZX1UECkjQgUj4rWF_2KA',
              'id': 'mapbox.mapbox-streets-v7'
            }),
        new MarkerLayerOptions(
          markers: [
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.296762, 103.773187),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.294326, 103.770037),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.293005, 103.774542),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),

            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.2923956, 103.77572039999995),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.292435, 103.781077),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.291997, 103.774681),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.290894, 103.78079),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.291405, 103.775671),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.292838, 103.771368),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
            new Marker(
              width: 45.0,
              height: 45.0,
              point: new LatLng(1.294796, 103.772489),
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: kMarker,
                      iconSize: 30.0,
                      onPressed: () {
                        print('Marker tapped');
                      },
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
