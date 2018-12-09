import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Home/HomePage.dart';
import 'package:flutterdabao/LoginSignup/ProcessingPage.dart';
import 'package:flutterdabao/LoginSignup/ProfileCreationPage.dart';
import 'package:flutterdabao/LoginSignup/LoginPage.dart';
import 'package:flutterdabao/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/LoginSignup/VerifyPhoneNumberPage.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:rxdart/rxdart.dart';

class DabaoApp extends StatelessWidget {
  // Add in all set up etc needed
  DabaoApp() {
    // debugPaintSizeEnabled=true;
    ConfigHelper.instance.appDidLoad();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DABAO',
      theme: ThemeData(fontFamily: "SF_UI_Display"),
      home: _handleCurrentScreen(),
    );
  }

  // Handles Authentication State
  // Navigation logic
  Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            if (snapshot.hasData) {
              //This Line of code is nesscery as it sets the current user in ConfigHelper
              User user = User.fromAuth(snapshot.data);

              //Check if its logged in
              return ProcessingPage(user);
            } else {
              return Navigator(onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (context) {
                  return LoginPage();
                });
              });
            }
          }
        });
  }

  /*
  // Handles Authentication State
  // Navigation logic
  Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            if (snapshot.hasData) {
              User user = User.fromAuth(snapshot.data);
              return StreamBuilder<String>(
                  stream: user.profileImage,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingPage();
                    } else if (snapshot.hasData) {
                      return new Navigator(
                        //popping all previous context and goes to the returned page
                          onGenerateRoute: (RouteSettings settings) {
                        return new MaterialPageRoute(builder: (context) {
                          return Home();
                        });
                      });
                    } else {
                      return new Navigator(
                          onGenerateRoute: (RouteSettings settings) {
                        return new MaterialPageRoute(builder: (context) {
                          return ProfileCreationPage();
                        });
                      });
                    }
                  });
            } else {
              return new Navigator(onGenerateRoute: (RouteSettings settings) {
                return new MaterialPageRoute(builder: (context) {
                  return LoginPage();
                });
              });
            }
          }
        });
  }*/

  /*
  // Handles Authentication State
  Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {

          print("TestingHello");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            if (snapshot.hasData) {
              // If Logged in, load user from FirebaseAuth
              //TODO add in check if user has completed profile creation else bring to profile creation;
              print("TestingHello22222");
              User user = User.fromAuth(snapshot.data);
              return StreamBuilder<String>(
                stream: user.profileImage,
                builder: (BuildContext context, snapshot) {
                  print(snapshot);
                  if (snapshot.connectionState == ConnectionState.waiting){
                    print("TestingHello333");
                    return LoadingPage();
                  } else if (snapshot.hasData) { //snapshot.data != null
                  print("TestingHello4444");
                    return Home();
                  } else {
                    print("TestingHello555");
                    return ProfileCreationPage();
                  }        
                }
                );
                
                //return Home();
            } else {
              return LoginPage();
            }
          }
        });
  }
  */
}
