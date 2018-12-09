import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Home/HomePage.dart';
import 'package:flutterdabao/LoginSignup/ProfileCreationPage.dart';
import 'package:flutterdabao/LoginSignup/VerifyPhoneNumberPage.dart';
import 'package:flutterdabao/Model/User.dart';

class ProcessingPage extends StatefulWidget {
  @override
  _ProcessingPageState createState() => new _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  @override
  void initState() {
    super.initState();
    User user = ConfigHelper.instance.currentUserProperty.value;
    if (user.handPhone.value == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerifyPhoneNumberPage()),
      );
    } else if (user.profileImage.value == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileCreationPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Text("GOD DAMMIT"),
      ],
    );
  }
}
