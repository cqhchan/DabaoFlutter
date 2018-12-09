import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/LoginSignup/PhoneSignupPage.dart';

class PhoneLoginPage extends StatefulWidget {
  PhoneLoginPage({Key key}) : super(key: key);
  @override
  _PhoneLoginPageState createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  String phoneNo;
  String smsCode;
  String verificationId;

  bool _autoValidate = false;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
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
                      Navigator.of(context).pop(); //To get rid of smsCodeDialog before moving on.
                      signIn();
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
        .signInWithCredential(PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode))
        .catchError((e) {
      print(e);
    });
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
                    'PHONE LOGIN',
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
                  child: Text('SIGN UP'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PhoneSignupPage()),
                    );
                  },
                ),
                  RaisedButton(
                    child: Text('LOG IN'),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    onPressed: verifyPhone,
                  ),
                  FlatButton(
                    child: Text('EMAIL LOGIN'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
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
