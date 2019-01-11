import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/LoginSignup/AuthPages.dart';
import 'package:flutterdabao/LoginSignup/EntryTextField.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {

  LoginPage({Key key}):super(key:key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // scale size when depressed
  final double minScale = 0;

  // scale size when undepressed
  final double maxScale = 1.0;

  // duration of animation in milliseconds
  final int animationDuration = 200;

  MutableProperty<int> selectedTabProperty = MutableProperty(0);
  MutableProperty<bool> phoneLogin = MutableProperty(true);
  MutableProperty<bool> expanded = MutableProperty(false);

  TabController _tabController;

  Animation<double> animation;

  AnimationController _animationController;
  ScaleTransition transition;

  Future<Null> _playAnimation() async {
    try {
      await _animationController.forward().orCancel;
      expanded.value = true;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  Future<Null> _reverseAnimation() async {
    try {
      expanded.value = false;

      await _animationController.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void initState() {
    print("init");
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 2);
    _tabController.addListener(() {
      selectedTabProperty.value = _tabController.index;
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: animationDuration),
    );
    animation =
        Tween(begin: maxScale, end: minScale).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              backGround(),
              // Expanded(child: Container(color: Colors.yellow,),),

              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: <Widget>[
                      tabBar(),
                      Expanded(
                        child: StreamBuilder<int>(
                          stream: selectedTabProperty.producer,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Offstage();
                            if (snapshot.data == 0) {
                              return loginTabLogic();
                            } else {
                              return signUpTabLogic();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget loginTabLogic() {
    return StreamBuilder(
      stream: expanded.producer,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();

        if (!snap.data) return buildLoginTab();
        return StreamBuilder(
            stream: phoneLogin.producer,
            builder: (context, snap) {
              if (!snap.hasData) return Offstage();
              if (snap.data) return PhoneVerificationPage();
              return EmailLoginPage();
            });
      },
    );
  }

  Widget signUpTabLogic() {
    return StreamBuilder(
      stream: expanded.producer,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        if (!snap.data) return buildSignUpTab();
        return PhoneVerificationPage();
      },
    );
  }

  Stack tabBar() {
    return Stack(children: <Widget>[
      TabBar(
        unselectedLabelColor: Color(0xFFD0D0D0),
        controller: _tabController,
        labelStyle: FontHelper.semiBold(Color(0xFF333333), 18),
        tabs: [
          Tab(text: "Log In"),
          Tab(text: "Sign Up"),
        ],
      ),
      StreamBuilder(
        stream: expanded.producer,
        builder: (context, snap) {
          if (!snap.hasData || !snap.data) {
            return Offstage();
          }
          return backArrow();
        },
      ) //Placed at the last item to be on top of stack so that icon button can work
    ]);
  }

  Widget backGround() {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return Stack(
          children: <Widget>[
            Container(
              height:
                  animation.value * (MediaQuery.of(context).size.height) * 0.5,
              // height: 0,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/images/splashbg.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomLeft,
              ),
            ),
            Container(
              height:
                  animation.value * (MediaQuery.of(context).size.height) * 0.5,
              // height: 0,

              decoration: BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.grey.withOpacity(0.0),
                      ],
                      stops: [
                        0.0,
                        1.0
                      ])),
            ),
            Positioned(
              left: 50,
              bottom: (MediaQuery.of(context).size.height - 150) * 0.1,
              child: Image.asset(
                'assets/images/LoginAppIcon.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomLeft,
              ),
            )
          ],
        );
      },
    );
  }

  //the default sign up page before the "Sign Me Up" button is selected
  Widget buildSignUpTab() {
    return Center(
        child: Container(
      padding: EdgeInsets.only(left: 40.0, right: 40.0),
      height: 40.0,
      child: OutlineButton(
        borderSide: BorderSide(color: ColorHelper.dabaoOffGrey70),
        child: Center(
          child: Container(
            height: 40,
            child: Center(
              child: Text(
                'SIGN ME UP!',
                style: FontHelper.semiBold(Color(0xFF454F63), 15.0),
              ),
            ),
          ),
        ),
        onPressed: () {
          _playAnimation();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
      ),
    ));
  }

  Widget buildLoginTab() {
    return Center(
      child: Container(
        padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 20, bottom: 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlineButton(
                borderSide: BorderSide(color: Color(0xFF707070)),
                child: Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.phone),
                        SizedBox(
                          width: 5,
                        ),
                        Text('LOG IN WITH MOBILE NO.',
                            style: FontHelper.semiBold(Color(0xFF454F63), 15.0))
                      ],
                    )),
                color: Color(0xFFFFFFFF),
                //elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                onPressed: () {
                  _playAnimation();
                  phoneLogin.value = true;
                },
              ),
              SizedBox(
                height: 20,
              ),
              OutlineButton(
                  borderSide: BorderSide(color: Color(0xFF707070)),
                  child: Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.email),
                          SizedBox(
                            width: 5,
                          ),
                          Text('LOG IN WITH EMAIL'),
                        ],
                      )),
                  color: ColorHelper.dabaoOffGreyD8,
                  //elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  onPressed: () {
                    _playAnimation();
                    phoneLogin.value = false;
                  }),
            ]),
      ),
    );
  }

  //The back arrow that appears when either login with mobile/login with email/sign up is selected
  Widget backArrow() {
    return Positioned(
        left: 5.0,
        bottom: 0.0,
        child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              _reverseAnimation();
            }));
  }
}
