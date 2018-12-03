import 'package:flutter/material.dart';

class Searchable extends StatefulWidget {
  _SearchableState createState() => _SearchableState();
}

class _SearchableState extends State<Searchable> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(title: Text('Hello World')),
        body: Center(
          child: Text('Hi'),
        ),
      ),
    );
  }
}
