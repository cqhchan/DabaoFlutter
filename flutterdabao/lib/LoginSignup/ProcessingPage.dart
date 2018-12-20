import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Home/HomePage.dart';
import 'package:flutterdabao/LoginSignup/ProfileCreationPage.dart';
import 'package:flutterdabao/LoginSignup/VerifyPhoneNumberPage.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:rxdart/rxdart.dart';

class ProcessingPage extends StatefulWidget {
  final User user;
  ProcessingPage(this.user);

  @override
  _ProcessingPageState createState() => new _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {

  @override
  Widget build(BuildContext context) {
    // There are 3 things that you check to see of it should go to ProfileCreation/Verification or Home
    // return true to go to home/ false to go to ProfileCreation

    
    return StreamBuilder<bool>(
      /*
        stream: Observable.combineLatest3(
            widget.user.email, widget.user.handPhone, widget.user.profileImage,
            (email, phoneNumber, profileImage) {
          if (email != null && phoneNumber != null && profileImage != null) {
            return true;
          } else {
            return false;
          }
        }),*/
        stream: widget.user.verified,
        builder: (BuildContext context, userSnapshot) {

          // GO STRAIGHT TO HOME IN DEBUG
          if (ConfigHelper.instance.isInDebugMode)
          return Home();


          if (userSnapshot.connectionState == ConnectionState.waiting ||
              !userSnapshot.hasData) {
            return LoadingPage();
          } else {
            if (userSnapshot.data == true) {
              return Navigator(onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (context) {
                  return Home();
                });
              });
            } else {
              if (widget.user.email.value != null && widget.user.verified.value == false) {
                //if this is old user
                return Navigator(onGenerateRoute: (RouteSettings settings) {
                  return MaterialPageRoute(builder: (context) {
                    return VerifyPhoneNumberPage();
                  });
                });
              } else {
                // if this is a new user
                return Navigator(onGenerateRoute: (RouteSettings settings) {
                  return MaterialPageRoute(builder: (context) {
                    return ProfileCreationPage();
                  });
                });
              }
            }
          }
        });
  }
}