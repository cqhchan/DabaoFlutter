import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/LoginSignup/EntryTextField.dart';

class NewLoginPage extends StatefulWidget {
  @override
  _NewLoginPageState createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // scale size when depressed
  final double minScale = 0;

  // scale size when undepressed
  final double maxScale = 1.0;

  // duration of animation in milliseconds
  final int animationDuration = 300;

  MutableProperty<int> selectedTabProperty = MutableProperty(0);

  String phoneNo = "+65";
  String smsCode;
  String verificationId;
  String _email;
  String _password;
  TabController _tabController;
  @override
  Animation<double> animation;
  AnimationController _animationController;
  ScaleTransition transition;
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool emailLoginSelected = false;
  bool signUpSelected = false;
  bool mobileLoginSelected = false;

  // _controller = AnimationController(vsync: this);

  Future<Null> _playAnimation() async {
    try {
      await _animationController.forward().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  Future<Null> _reverseAnimation() async {
    try {
      await _animationController.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initState() {
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

    super.initState();
  }

  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      content: new Text(message),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Widget buildSignUpTab() {
    return Container(
        height: 200,
        padding: EdgeInsets.only(left: 12.0, right: 12.0),
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
                      Icon(Icons.sentiment_very_satisfied),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'SIGN ME UP!',
                        style: FontHelper.semiBold(Color(0xFF454F63), 15.0),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.sentiment_very_satisfied),
                    ],
                  )),
              color: Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              onPressed: () {
                _playAnimation();
                setState(() {
                  signUpSelected = true;
                });
              },
            ),
          ],
        ));
  }

  //////PHONE LOGIN AND SIGN UP/////////////////////////////////
  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      verificationId = verId;
    };
    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      print('verified');
    };
    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  //THIS IS THE CAUSE OF ERROR!!!!

  signInWithPhone() async {
    try{
      print("HELLO");
    FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.getCredential(
            verificationId: verificationId, smsCode: smsCode))
        .catchError((e) {
      _showSnackBar("Wrong Code");
    });
    } catch(e) {
      print("HOHO");
      _showSnackBar("Wrong Code");
    }
  }

  void _validate() {
    final form = _formKey.currentState;
    if (form.validate()) {
      // Text forms was validated.
      form.save();
      // setState(() {
      //   _inProgress = true;
      // });
      verifyPhone();
    } else {
      setState(() => _autoValidate = true);
    }
  }

  String _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return "Enter Phone number";
    } else if (value.length != 8 || (value[0] != '8' && value[0] != '9')) {
      return "Invalid Phone Number";
    }
  }

  //Sign up and Mobile Login Page
  //Displayed after user selected login with mobile number or signup
  Widget buildSignUpPage() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              children: <Widget>[
                SizedBox(height: 96.0),
                Text('SIGNUP',
                    style: Theme.of(context).textTheme.headline,
                    textAlign: TextAlign.center),
                SizedBox(height: 80.0),
                Text(
                  'Please Enter A Singapore Mobile Number',
                  style: Theme.of(context).textTheme.title,
                ),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Text(
                      '+65',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Enter Phone Number',
                        ),
                        onSaved: (value) {
                          phoneNo = "+65" + value;
                        },
                        validator: _validatePhoneNumber,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                RaisedButton(
                  child: Text('SIGN UP'),
                  color: Colors.orange[300],
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  ),
                  onPressed: _validate,
                ),
              ],
            )));
  }

  //Email Login Page
  //Displayed after user pressed "Login with Email"
  Widget buildEmailLoginPage() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 70.0),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: Color(0xFF454F63)),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                controller: _usernameController,
                style: TextStyle(color: Color(0xFFD0D0D0)),
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.email,
                    color: Color(0xFFD0D0D0),
                  ),
                  hintText: 'Email',
                  fillColor: Color(0xFFD0D0D0),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 12.0),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: Color(0xFF454F63)),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                controller: _passwordController,
                style: FontHelper.semiBoldgrey16TextStyle,
                obscureText: true,
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.email,
                    color: Color(0xFFD0D0D0),
                  ),
                  hintText: 'Password',
                  fillColor: Color(0xFFD0D0D0),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            RaisedButton(
                child: Container(
                  height: 40,
                  child: Center(
                    child: Text(
                      'LOG IN',
                      style: FontHelper.overlayHeader,
                    ),
                  ),
                ),
                color: Color(0xFFF5A510),
                elevation: 2.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                onPressed: () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _email, password: _password)
                      .catchError((e) {
                    _showSnackBar('Wrong username and password!');
                    print(e);
                  });
                }),
          ],
        ));
  }

  Widget buildLoginTab() {
    return Container(
      height: 200,
      padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 20, bottom: 20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                setState(() {
                  mobileLoginSelected = true;
                });
              },
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
                  setState(() {
                    emailLoginSelected = true;
                  });
                }),
          ]),
    );
  }

  //Sign up and Mobile Login Page
  //Displayed after user selected login with mobile number or signup
  Widget buildMobileLoginPage() {
    return Column(children: <Widget>[
      Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 70.0),
                  Text("Enter your Mobile Number",
                      style: FontHelper.semiBold(Color(0xFF000000), 18)),
                  SizedBox(
                    height: 15,
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            border: Border.all(color: Color(0xFF707070)),
                          ),
                          child: TextFormField(
                            onSaved: (value) {
                              setState(() {
                                phoneNo = "+65" + value;
                              });
                            },
                            validator: _validatePhoneNumber,
                            keyboardType: TextInputType.number,
                            style: FontHelper.semiBoldgrey16TextStyle,
                            decoration: InputDecoration(
                              prefixText: "+65 ",
                              prefixStyle:
                                  FontHelper.semiBold(Color(0xFF000000), 22),
                              hintText: 'Mobile No.',
                              fillColor: Colors.white,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 1, child: SizedBox(width: 5)),
                      Expanded(
                          flex: 4,
                          child: OutlineButton(
                            borderSide: BorderSide(color: Color(0xFF707070)),
                            child: Container(
                                child: Text('SEND OTP',
                                    style: FontHelper.semiBold(
                                        Color(0xFF454F63), 14))),
                            color: Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                            ),
                            onPressed: _validate,
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Please enter the verification code sent to",
                        style: FontHelper.semiBold(Color(0xFF454F63), 14),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        phoneNo,
                        style: FontHelper.semiBold(Color(0xFF454F63), 14),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  PinEntryTextField(
                    fieldHeight: 40.0,
                    fieldWidth: 30.0,
                    midGap: 15.0,
                    onSubmit: (String pin) {
                      print(pin);
                      setState(() {
                        this.smsCode = pin;
                      });
                      print(pin);
                      signInWithPhone();
                    },
                  ),
                ]),
          ))
    ]);
  }

  Widget loginTabLogic() {
    if (emailLoginSelected) {
      return buildEmailLoginPage();
    } else if (mobileLoginSelected) {
      return buildMobileLoginPage();
    } else {
      return buildLoginTab();
    }
  }

  Widget signUpTabLogic() {
    if (signUpSelected) {
      return buildMobileLoginPage();
    } else {
      return buildSignUpTab();
    }
  }

  Widget backArrow() {
    if (mobileLoginSelected || emailLoginSelected || signUpSelected) {
      return Positioned(
          left: 10.0,
          bottom: 25.0,
          child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                _reverseAnimation();
                setState(() {
                  mobileLoginSelected = false;
                  emailLoginSelected = false;
                  signUpSelected = false;
                });
              }));
    } else {
      return Positioned(
          //this is just a placeholder
          child: Text(""));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              Flexible(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget child) {
                    return Container(
                        height: animation.value *
                            (MediaQuery.of(context).size.height - 250),
                        width: MediaQuery.of(context).size.width,
                        // child: ScaleTransition(
                        // scale: animation,
                        child: Image.asset(
                          'assets/images/splashbg.png',
                          fit: BoxFit.cover,
                        )
                        // ),
                        );
                  },
                ),
              ),
              SafeArea(
                child: Column(
                  children: <Widget>[
                    Stack(children: <Widget>[
                      TabBar(
                        controller: _tabController,
                        labelStyle: FontHelper.header3TextStyle,
                        tabs: [
                          Tab(
                              icon: Icon(Icons.add_to_home_screen),
                              text: "Log In"),
                          Tab(icon: Icon(Icons.border_color), text: "Sign Up"),
                        ],
                      ),
                      backArrow(), //Placed at the last item to be on top of stack so that icon button can work
                    ]),
                    StreamBuilder<int>(
                      stream: selectedTabProperty.producer,
                      builder: (context, snapshot) {
                        if (snapshot.data == 0) {
                          return loginTabLogic();
                        } else {
                          return signUpTabLogic();
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
