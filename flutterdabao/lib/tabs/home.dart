import 'package:flutter/material.dart';

import 'package:flutterdabao/style/home_style.dart';
import 'package:flutterdabao/screens/dabaoer.dart';
import 'package:flutterdabao/screens/dabaoee.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => new _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new Container(
          decoration: BoxDecoration(
            color: kBackground,
          ),
          child: Stack(
            children: <Widget>[
              new ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[
                  new SizedBox(height: 30.0),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new CircleAvatar(
                          child: Image.asset('assets/CandyMonsterEdited.png'),
                        ),
                        new Text(' Hi, $name!'),
                      ]),
                  new SizedBox(height: 30.0),
                  new Row(
                    children: <Widget>[
                      new Text(
                        'What can we',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: kText,
                            fontWeight: FontWeight.bold,
                            fontSize: 40.0),
                      ),
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      Text(
                        'serve you',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: kText,
                            fontWeight: FontWeight.bold,
                            fontSize: 40.0),
                      ),
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text(
                        'today?',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: kText,
                            fontWeight: FontWeight.bold,
                            fontSize: 40.0),
                      ),
                    ],
                  ),
                  new SizedBox(height: 30.0),
                  new RaisedButton(
                    elevation: 0.0,
                    highlightElevation: 0.0,
                    color: kDeliverButton,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(50.0)),
                    child: new Text('I WANT TO DELIVERY (DABAOER)'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dabaoer()),
                      );
                    },
                  ),
                  new SizedBox(height: 10.0),
                  new RaisedButton(
                    elevation: 4.0,
                    highlightElevation: 2.0,
                    color: kOrderButton,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(50.0)),
                    child: new Text('I WANT TO ORDER (DABAOEE)'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Dabaoee()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
