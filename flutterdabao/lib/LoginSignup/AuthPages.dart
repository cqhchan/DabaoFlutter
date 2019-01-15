import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/HelperClasses/AuthHandler.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/LoginSignup/EntryTextField.dart';
import 'package:flutterdabao/Model/User.dart';

class PhoneVerificationPage extends StatefulWidget {
  final bool linkCredentials;
  final VoidCallback onCompleteCallback;

  const PhoneVerificationPage(
      {Key key, this.linkCredentials = false, this.onCompleteCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PhoneVerificationPageState();
  }
}

class PhoneVerificationPageState extends State<PhoneVerificationPage>
    with AuthHandler {
  String countryCode = "+65";
  String phoneNumber = "";
  bool otpsent = false;
  final _phoneNumberController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSignUpPage();
  }

  //sign up page that shows up after signup button is pressed
  Widget buildSignUpPage() {
    return SingleChildScrollView(
          child: GestureDetector(
        onTap: _focusNode.unfocus,
        child: Container(
          padding: EdgeInsets.fromLTRB(18.0, 40.0, 18.0, 0.0),
          color: Colors.transparent,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildHeader(),
                SizedBox(
                  height: 15,
                ),
                buildNumberEnterArea(),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 60.0,
                  child: otpsent
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                "Please enter the verification code sent to",
                                style: FontHelper.semiBold(Color(0xFF454F63), 14),
                              ),
                            ),
                            Text(
                              countryCode + phoneNumber,
                              style: FontHelper.semiBold(Color(0xFF454F63), 14),
                            )
                          ],
                        )
                      : Container(
                          height: 60,
                        ),
                ),
                PinEntryTextField(
                  fieldHeight: 40.0,
                  fieldWidth: 30.0,
                  midGap: 15.0,
                  enableTextField: otpsent,
                  onSubmit: (String pin) async {
                    this.smsCode = pin;
                    showLoadingOverlay(context: context);

                    if (!widget.linkCredentials) {
                      await signInWithPhone().then((FirebaseUser firebaseUser) {
                        // Navigator.of(context).pop();

                        User.fromAuth(firebaseUser)
                            .setPhoneNumber(firebaseUser.phoneNumber);

                        if (widget.onCompleteCallback != null)
                          widget.onCompleteCallback();
                      }).catchError((e) {
                        Navigator.of(context).pop();
                        _showSnackBar("Error incorrect wrong code");
                      });
                    } else {
                      linkCredentialsWithPhone().then((firebaseUser) {
                        Navigator.of(context).pop();
                        User.fromAuth(firebaseUser)
                            .setPhoneNumber(firebaseUser.phoneNumber);
                        if (widget.onCompleteCallback != null)
                          widget.onCompleteCallback();
                      }).catchError((e) {
                        Navigator.of(context).pop();

                        switch (e.code) {
                          case "ERROR_REQUIRES_RECENT_LOGIN":
                            FirebaseAuth.instance.signOut();
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Please Login Again"),
                                    actions: <Widget>[
                                      new FlatButton(
                                        child: new Text(
                                          "DISMISS",
                                          style: FontHelper.regular(
                                              Colors.black, 14.0),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                            break;

                          case "ERROR_INVALID_CREDENTIAL":
                            _showSnackBar('Unknown Error');

                            break;

                          case "ERROR_WEAK_PASSWORD":
                            _showSnackBar(
                                'Weak Password. Must be more than 6 characters');

                            break;

                          case "ERROR_CREDENTIAL_ALREADY_IN_USE":
                            _showSnackBar('Phone Number already in use');

                            break;

                          case "ERROR_USER_DISABLED":
                            _showSnackBar('Unknown Error');

                            break;

                          case "ERROR_PROVIDER_ALREADY_LINKED":
                            _showSnackBar('Phone Number already linked');

                            break;

                          case "ERROR_OPERATION_NOT_ALLOWED":
                            _showSnackBar('Check your network connectivity');

                            break;

                          default:
                            _showSnackBar(e.message);
                        }
                      });
                    }
                  },
                ),
              ]),
        ),
      ),
    );
  }

  Flex buildNumberEnterArea() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Container(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              border: Border.all(color: Color(0xFF707070)),
            ),
            child: TextFormField(
              autocorrect: false,
              focusNode: _focusNode,
              controller: _phoneNumberController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
              ],
              keyboardType: TextInputType.numberWithOptions(),
              style: FontHelper.semiBold(Color(0xFF000000), 15),
              decoration: InputDecoration(
                prefixText: "+65 ",
                prefixStyle: FontHelper.semiBold(Color(0xFF000000), 15),
                hintText: '9XXXXXXX',
                hintStyle: FontHelper.semiBold(Color(0xFFD0D0D0), 15),
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Expanded(flex: 1, child: SizedBox(width: 5)),
        Container(
          height: 42,
          width: 120,
          child: OutlineButton(
              borderSide: otpsent
                  ? BorderSide(color: ColorHelper.dabaoErrorRed)
                  : BorderSide(color: Color(0xFF707070)),
              child: otpsent
                  ? Container(
                      child: Text('RESEND OTP',
                          maxLines: 1,
                          style: FontHelper.semiBold(ColorHelper.dabaoErrorRed, null)))
                  : Container(
                      child: Text('SEND OTP',
                          maxLines: 1,
                          style: FontHelper.semiBold(Color(0xFF454F63), null))),
              color: Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              onPressed: () {
                _validate();
              }),
        )
      ],
    );
  }

  Text buildHeader() {
    return Text("Enter your Mobile Number",
        style: FontHelper.semiBold(Color(0xFF000000), 18));
  }

  void _validate() {
    if (StringHelper.validatePhoneNumber(_phoneNumberController.text)) {
      // Text forms was validated.
      verifyPhone(
          linkCredentials: widget.linkCredentials,
          phoneNumber: countryCode + _phoneNumberController.text,
          smsSent: () {
            setState(() {
              phoneNumber = _phoneNumberController.text;
              otpsent = true;
            });
          },
          success: (sucess) async {
            await FirebaseAuth.instance.currentUser().then((firebaseUser) {
              User.fromAuth(firebaseUser)
                  .setPhoneNumber(firebaseUser.phoneNumber);
            });

            if (widget.onCompleteCallback != null) widget.onCompleteCallback();
          },
          failed: (failed) {
            setState(() {
              otpsent = false;
            });
            FirebaseAuth.instance.signOut();
            _showSnackBar("Verification Failed");
          });
    } else {
      _showSnackBar("Invalid Phone Number");
    }
  }

  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      content: new Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

class EmailLoginPage extends StatefulWidget {
  final bool linkCredentials;
  final VoidCallback onCompleteCallback;

  const EmailLoginPage(
      {Key key, this.linkCredentials = false, this.onCompleteCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EmailLoginPageState();
  }
}

class EmailLoginPageState extends State<EmailLoginPage> with AuthHandler {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildEmailLoginPage();
  }

  Widget buildEmailLoginPage() {
    return GestureDetector(
        onTap: _focusNode.unfocus,
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: 70.0),
                Container(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Color(0xFF454F63)),
                  child: TextField(
                    controller: _usernameController,
                    style: FontHelper.semiBold(Color(0xFFD0D0D0), 16),
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: Color(0xFFD0D0D0),
                      ),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Color(0xFFD0D0D0)),
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
                    controller: _passwordController,
                    style: FontHelper.semiBoldgrey16TextStyle,
                    obscureText: true,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.lock,
                        color: Color(0xFFD0D0D0),
                      ),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Color(0xFFD0D0D0)),
                      fillColor: Color(0xFFD0D0D0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                RaisedButton(
                    child: Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          widget.linkCredentials
                              ? 'SET EMAIL AND PASSWORD'
                              : 'LOG IN',
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
                      _focusNode.unfocus();

                      if (!widget.linkCredentials) {
                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _usernameController.text,
                                password: _passwordController.text)
                            .then((firebaseUser) {
                          User.fromAuth(firebaseUser)
                              .setEmail(firebaseUser.email);
                          if (widget.onCompleteCallback != null)
                            widget.onCompleteCallback();
                        }).catchError((e) {
                          switch (e.code) {
                            case "ERROR_INVALID_EMAIL":
                              _showSnackBar('Email is not valid');

                              break;
                            case "ERROR_WRONG_PASSWORD":
                              _showSnackBar('Wrong username and password!');

                              break;
                            case "ERROR_USER_NOT_FOUND":
                              _showSnackBar('Wrong username and password!');

                              break;
                            case "ERROR_USER_DISABLED":
                              _showSnackBar('Email has been banned');

                              break;
                            case "ERROR_TOO_MANY_REQUESTS":
                              _showSnackBar(
                                  'Too many attempts, please try again later');
                              break;

                            case "ERROR_OPERATION_NOT_ALLOWED":
                              _showSnackBar('Unknown Error');

                              break;
                            default:
                              _showSnackBar(e.message);
                          }
                          print(e);
                        });
                      } else {
                        FirebaseAuth.instance
                            .linkWithCredential(EmailAuthProvider.getCredential(
                                email: _usernameController.text,
                                password: _passwordController.text))
                            .then((firebaseUser) {
                          User.fromAuth(firebaseUser)
                              .setEmail(firebaseUser.email);
                          if (widget.onCompleteCallback != null)
                            widget.onCompleteCallback();
                        }).catchError((e) {
                          print(e);
                          switch (e.code) {
                            case "ERROR_REQUIRES_RECENT_LOGIN":
                              print("Logout");
                              // _showSnackBar('Please Login Again');
                              FirebaseAuth.instance.signOut();

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Please Login Again"),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: new Text(
                                            "DISMISS",
                                            style: FontHelper.regular(
                                                Colors.black, 14.0),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });

                              break;

                            case "ERROR_INVALID_CREDENTIAL":
                              print("Logout");
                              _showSnackBar('Unknown Error');

                              break;

                            case "ERROR_WEAK_PASSWORD":
                              _showSnackBar(
                                  'Weak Password. Must be more than 6 characters');

                              break;

                            case "ERROR_EMAIL_ALREADY_IN_USE":
                              _showSnackBar('Email already in use');

                              break;

                            case "ERROR_USER_DISABLED":
                              _showSnackBar('Unknown Error');

                              break;

                            case "ERROR_PROVIDER_ALREADY_LINKED":
                              _showSnackBar('Email already linked');

                              break;

                            case "ERROR_OPERATION_NOT_ALLOWED":
                              _showSnackBar('Check your network connectivity');

                              break;

                            default:
                              _showSnackBar(e.message);
                          }
                        });
                      }
                    }),
                SizedBox(
                  height: 10,
                ),
                widget.linkCredentials
                    ? GestureDetector(
                        child: Text("Skip"),
                        onTap: () {
                          widget.onCompleteCallback();
                        },
                      )
                    : Offstage(),
                Expanded(
                  child: Container(),
                ),
              ],
            )));
  }

  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      content: new Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
