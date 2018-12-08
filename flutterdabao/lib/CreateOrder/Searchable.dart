import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/CustomizedBackButton.dart';
// import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';

class Searchable extends StatefulWidget {
  _SearchableState createState() => _SearchableState();
}

class _SearchableState extends State<Searchable> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Text('Hello World'),
          ),
          CustomizedBackButton(),
        ],
      ),
    ));
  }
}
