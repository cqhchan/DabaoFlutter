import 'package:flutter/material.dart';

import '../initial/login.dart';

import '../screens/faq.dart';
import '../screens/support.dart';
import '../screens/transaction.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new Container(
          child: new ListView(
        children: <Widget>[
          new Container(
            height: 120.0,
            child: new DrawerHeader(
              padding: new EdgeInsets.all(6.0),
              decoration: new BoxDecoration(
                color: new Color(0xFFECEFF1),
              ),
              child: new Center(
                  child: new Image.asset('assets/CandyMonsterEdited.png')),
            ),
          ),
          new ListTile(
            leading: new Icon(Icons.history),
            title: new Text('Past Transactions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => Transaction()),
              );
            },
          ),
          new ListTile(
            leading: new Icon(Icons.chat),
            title: new Text('Frequent Asked Questions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => FAQ()),
              );
            },
          ),
          new ListTile(
            leading: new Icon(Icons.info),
            title: new Text('Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => Support()),
              );
            },
          ),
          new Divider(),
          new ListTile(
            leading: new Icon(Icons.exit_to_app),
            title: new Text('Sign Out'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()),
              );
            },
          ),
        ],
      ));
}
