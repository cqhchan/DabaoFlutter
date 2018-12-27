import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PhoneSignupPage extends StatefulWidget {
  PhoneSignupPage({Key key}) : super(key: key);
  @override
  _PhoneSignupPageState createState() => _PhoneSignupPageState();
}

class _PhoneSignupPageState extends State<PhoneSignupPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String phoneNo;
  String smsCode;
  String verificationId;
  bool _inProgress = false;

  bool _autoValidate = false;

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
              new FlatButton(
                child: Text('Verify'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    //only need to signIn if verification is not done automatically
                    if (user == null) {
                      //Navigator.of(context).pop();
                      Navigator.of(context)
                          .pop(); //To get rid of smsCodeDialog before moving on.
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  //THIS SHOULD BE A CAUSE OF BUG, TAKE NOTE
  signIn() async {
    FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.getCredential(
            verificationId: verificationId, smsCode: smsCode))
        .catchError((e) {
          _showSnackBar(e);
      print(e);
    }).catchError((e) {
      print(e);
    });
  }
  
  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      content: new Text(message),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
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
                    color: Colors.orange[300],
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    onPressed: _validate,
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
