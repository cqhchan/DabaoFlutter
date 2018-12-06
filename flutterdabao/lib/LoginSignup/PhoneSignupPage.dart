import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutterdabao/LoginSignup/LoginPage.dart';
import 'package:flutterdabao/LoginSignup/ProfileCreationPage.dart';

class PhoneSignupPage extends StatefulWidget {
  PhoneSignupPage({Key key}) : super(key: key);
  @override
  _PhoneSignupPageState createState() => _PhoneSignupPageState();
}

class _PhoneSignupPageState extends State<PhoneSignupPage> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String phoneNo;
  String smsCode;
  String verificationId;

  bool _autoValidate = false;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      print("Test1");
      verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      print("Test2");
      verificationId = verId;
      smsCodeDialog(context).then((value) {
        print('Signed in');
      });
    };
    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      print('verified');
      print(user.uid);
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

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter sms Code'),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Verify'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    //only need to signIn if verification is not done automatically
                    if (user == null) {
                      //Navigator.of(context).pop();
                      Navigator.of(context).pop(); //To get rid of smsCodeDialog before moving on.
                      signIn();
                      //Quick fix to profile page because app.dart didn't direct me to signup like it's suppose to
                      /*
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileCreationPage())
                      );
                      */
                    }
                  });
                },
              )
            ],
          );
        });
  }

  signIn() {
    FirebaseAuth.instance
        .signInWithPhoneNumber(verificationId: verificationId, smsCode: smsCode)
        .catchError((e) {
      print(e);
    });
  }
  /*
  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      content: new Text(message),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }*/

  String _validateEmail(String value) {
    if (value.isEmpty) {
      // The form is empty
      return "Enter email address";
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return 'Email is not valid';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
      body: SafeArea(
        child: Form(
          //key: _formKey,
          autovalidate: _autoValidate,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 80.0),
              Column(
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    'SIGNUP',
                    style: Theme.of(context).textTheme.headline,
                  ),
                ],
              ),
              SizedBox(height: 100.0),
              TextField(
                decoration: InputDecoration(hintText: 'Enter Phone number'),
                onChanged: (value) {
                  phoneNo = value;
                },
              ),
              SizedBox(height: 12.0),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text('CANCEL'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    child: Text('SIGN UP'),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    onPressed: verifyPhone,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
