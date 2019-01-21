import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/CustomWidget/page_turner_widget.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Home/HomePage.dart';
import 'package:flutterdabao/LoginSignup/AuthPages.dart';
import 'package:flutterdabao/LoginSignup/ProfileCreationPage.dart';
import 'package:flutterdabao/LoginSignup/WelcomePage.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';

class ProcessingPage extends StatefulWidget {
  final User user;
  ProcessingPage({Key key, this.user}) : super(key: key);

  @override
  _ProcessingPageState createState() => new _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> with PageHandler {
  List<Widget> listOfWidget;
  MutableProperty<int> currentPage = MutableProperty<int>(0);
  Observable<List<Widget>> listOfWidgetProducer;
  @override
  void initState() {
    super.initState();

    listOfWidgetProducer =
        Observable.combineLatest3<String, String, FirebaseUser, List<Widget>>(
            widget.user.email,
            widget.user.profileImage,
            FirebaseAuth.instance.currentUser().asStream(),
            (email, profileImage, firebaseUser) {
      List<Widget> list = List();

      if (firebaseUser.phoneNumber == null)
        list.add(Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            PhoneVerificationPage(
              linkCredentials: true,
              onCompleteCallback: nextPage,
            ),
            GestureDetector(
              onTap: (){
                FirebaseAuth.instance.signOut();
              },
              child: Container(color: Colors.transparent, child: Text("Sign in with a Different Account"))),
          ],
        )));

      if (profileImage == null ||
          firebaseUser.phoneNumber == null) if ((firebaseUser.email ==
              null ||
          firebaseUser.email.isEmpty))
        list.add(Scaffold(
            key: scaffoldKey,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Add Email (Optional)",
                        style: FontHelper.semiBold(Colors.black, 18.0),
                      )),
                  Flexible(
                      child: EmailLoginPage(
                    linkCredentials: true,
                    onCompleteCallback: () {
                      nextPage();
                    },
                  )),
                ],
              ),
            )));

      if (profileImage == null)
        list.add(ProfileCreationPage(
          key: profileKey,
          onCompleteCallback: () {
            nextPage();
          },
        ));

      return list;
    });
  }

  @override
  // TODO: implement maxPage + 2 cause firstPage and HomePage
  int get maxPage => listOfWidget.length + 2;

  @override
  Widget pageForNumber(int pageNumber) {
    if (pageNumber == null) return LoadingPage();

    if (pageNumber == 0)
      return WelcomePage(
        nextPage: () {
          nextPage();
        },
        numberOfSteps: listOfWidget.length,
      );

    if (pageNumber <= listOfWidget.length) return listOfWidget[pageNumber - 1];

    return Home();
  }

  @override
  // TODO: implement pageNumberSubject
  BehaviorSubject<int> get pageNumberSubject => currentPage.producer;

  Key profileKey = Key(randomString(20));
  Key scaffoldKey = Key(randomString(20));

  @override
  Widget build(BuildContext context) {
    // There are 3 things that you check to see of it should go to ProfileCreation/Verification or Home
    // return true to go to home/ false to go to ProfileCreation
    return StreamBuilder<List<Widget>>(
        stream: listOfWidgetProducer,
        builder: (BuildContext context, snap) {
          // GO STRAIGHT TO HOME IN DEBUG
          // if (ConfigHelper.instance.isInDebugMode)
          // return Home();

          if (snap.connectionState == ConnectionState.waiting ||
              !snap.hasData) {
            return LoadingPage();
          }

          if (snap.data.isEmpty) return Home();

          listOfWidget = snap.data;
          return PageTurner(this);
        });
  }
}
