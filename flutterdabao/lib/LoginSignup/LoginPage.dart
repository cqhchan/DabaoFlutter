import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/Mappable.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage>
    with SingleTickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Container(
        alignment: FractionalOffset(0.5, 0.5),
        child: Text("LOGIN BABY",
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