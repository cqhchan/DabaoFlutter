// import 'package:flutter/material.dart';
// import 'package:flutterdabao/ExtraProperties/Mappable.dart';
// import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
// import 'package:flutterdabao/Firebase/FirebaseType.dart';

// class LoginPage extends StatefulWidget {

//   @override
//   _LoginState createState() => _LoginState();
// }

// class _LoginState extends State<LoginPage>
//     with SingleTickerProviderStateMixin {


//   @override
//   Widget build(BuildContext context) {


//     return Scaffold(
//       body: Container(
//         alignment: FractionalOffset(0.5, 0.5),
//         child: Text("LOGIN BABY",
//         style: TextStyle(color: Colors.black, fontSize: 30.0),),
//       ),
//       backgroundColor: ColorHelper.dabaoOrange,
//     );

//   }

//   @override
//   void didUpdateWidget(Widget oldWidget){

//     super.didUpdateWidget(oldWidget);

//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/LoginSignup/PhoneSignupPage.dart';

import 'package:flutterdabao/LoginSignup/SignupPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _email;
  String _password;

  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      content: new Text(message),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                SizedBox(height: 16.0),
                Text(
                  'LOG IN',
                  style: Theme.of(context).textTheme.headline,
                ),
              ],
            ),
            SizedBox(height: 100.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'E-mail',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
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
                      //MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                ),
                RaisedButton(
                  child: Text('LOG IN'),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  ),
                  onPressed: () {
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _email, password: _password)
                        .catchError((e) {
                          _showSnackBar('Wrong username and password!');
                          print(e);
                        });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
