import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/Mappable.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<LoginPage>
    with SingleTickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {



    return new Scaffold(
      body: new Container(
        alignment: new FractionalOffset(0.5, 0.5),
        child: new Text("LOGIN BABY",
        style: TextStyle(color: Colors.black, fontSize: 30.0),),
      ),
      backgroundColor: ColorHelper.dabaoOrange,
    );

  }

  @override
  void didUpdateWidget(Widget oldWidget){

    super.didUpdateWidget(oldWidget);

  }
}