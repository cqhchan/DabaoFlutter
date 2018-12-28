import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Home/HomePage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class VerifyPhoneNumberPage extends StatefulWidget {
  VerifyPhoneNumberPage({Key key}) : super(key: key);
  @override
  _VerifyPhoneNumberPageState createState() => _VerifyPhoneNumberPageState();
}

class _VerifyPhoneNumberPageState extends State<VerifyPhoneNumberPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String phoneNo;
  String smsCode;
  String verificationId;
  bool _inProgress = false;

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
  }

  void _validate() {
    final form = _formKey.currentState;
    if (form.validate()) {
      // Text forms was validated.
      form.save();
      setState(() {
        _inProgress = true;
      });
      verifyPhone();
    } else {
      setState(() => _autoValidate = true);
    }
  }

  String _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return "Enter Phone number";
    } else if (value.length != 8){
      return "Singapore's phone number should be eight digits long";
    } else if (value[0] != '8' && value[0] != '9') {
      return "Please enter a valid phone number";
    }
  }

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
        linkCredentials: true,
        phoneNumber: phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    setState(() {
      _inProgress = false;
    });
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
              FlatButton(
                child: Text('Verify'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    Navigator.of(context)
                        .pop(); //To get rid of smsCodeDialog before moving on.
                    signIn();
                    //Quick fix to profile page because app.dart didn't direct me to signup like it's suppose to
                  });
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  signIn() {
    FirebaseAuth.instance.linkWithCredential(PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode));
    FirebaseAuth.instance.currentUser().then((user) {
      ConfigHelper.instance.currentUserProperty.value.setPhoneNumber(
          phoneNo); // this will make the verify boolean turn true
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }).catchError((e) {
      print(e);
      _showSnackBar("This mobile number is already in use");
    });
  }

  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      content: new Text(message),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }


  Widget buildWidget() {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 96.0),
                  Text(
                    'VERIFYING YOUR PHONE NUMBER',
                    style: Theme.of(context).textTheme.headline,
                    textAlign: TextAlign.center,
                  ),
                
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
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    color: ColorHelper.dabaoOrange,
                    child: Text('CONFIRM'),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    onPressed: _validate,
                  ),
                  RaisedButton(
                    child: Text('LOGOUT'),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(child: buildWidget(), inAsyncCall: _inProgress);
  }
}
