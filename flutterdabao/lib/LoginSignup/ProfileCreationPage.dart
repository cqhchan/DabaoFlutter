import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Home/HomePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:image/image.dart' as Resize;
import 'package:path_provider/path_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileCreationPage extends StatefulWidget {
  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name;
  String _phoneNumber;
  String _email;
  String _password;
  bool passwordVisibility = true;
  String verificationId;
  String smsCode;
  File _image;
  File _thumbnail;
  //for loading spinner, appears if true, hidden if false
  bool _inProgress = false;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _phoneNumber = user.phoneNumber;
      });
    });
  }

  ///////////////////////////////////////////////////////////////////////////////
  //IMAGE PROCESSING/////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////

  //Pre-condition: Called only when _image has been set
  void creatingThumbnail() {
    getTemporaryDirectory().then((tempDir) {
      String tempPath = tempDir.path;
      Resize.Image resizedImage = Resize.decodeImage(_image.readAsBytesSync());
      // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
      Resize.Image thumbnail = Resize.copyResize(resizedImage, 100, 100);
      // Save the thumbnail as a PNG.
      var thumbnailImage = new File(tempPath + 'thumbnailImage.png')
        ..writeAsBytesSync(Resize.encodePng(thumbnail));
      _thumbnail = thumbnailImage;
      setState(() {
        _inProgress = false;
      });
    });
  }

  //get image from camera
  void getImageFromCamera() async {
    setState(() {
      _inProgress = true;
    });

    ImagePicker.pickImage(source: ImageSource.camera).then((image) async {
      if (image == null) {
        setState(() {
          _inProgress = false;
        });
      } else {
        var croppedImage =
            await _cropImage(image); //give user the cropping option
        setState(() {
          _image = croppedImage;
        });
        creatingThumbnail();
      }
    }).catchError((e) {
      print(e);
      setState(() {
        _inProgress = false;
      });
    });
  }

  //Providing the UI for user to crop profile image chosen from camera/gallery
  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 300,
      maxHeight: 300,
    );
    return croppedFile;
  }

  //get image from gallery
  void getImageFromGallery() async {
    setState(() {
      _inProgress = true;
    });

    ImagePicker.pickImage(source: ImageSource.gallery).then((image) async {
      if (image == null) {
        setState(() {
          _inProgress = false;
        });
      } else {
        var croppedImage =
            await _cropImage(image); //give user the cropping option
        setState(() {
          _image = croppedImage;
        });
        creatingThumbnail();
      }
    });
  }
  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  //TO DEAL WITH "ERROR_REQUIRES_RECENT_LOGIN" EXCEPTION/////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
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
        phoneNumber: _phoneNumber,
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
                      Navigator.of(context)
                          .pop(); //To get rid of smsCodeDialog before moving on.
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

  signIn() async {
    FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.getCredential(
            verificationId: verificationId, smsCode: smsCode))
        .then((user) {})
        .catchError((e) {
      print(e);
    }).catchError((e) {
      print(e);
    });
  }
  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  //PROFILE CREATION FUNCTIONS///////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
  void createProfile() {
    //if-else statements prevent user from proceeding further if they have not filled up credentials properly yet
    if (_image == null) {
      _showSnackBar("Please upload a profile image");
      return;
    }

    //To activate for loading spinner
    setState(() {
      _inProgress = true;
    });

    //setting email first. In this function, it will call upload image
    addEmailCredentials();

    //Deactivating loading spinner
    setState(() {
      _inProgress = false;
    });
  }

  //only works if you are creating a new account
  void addEmailCredentials() {
    //FirebaseAuth.instance.crea
    FirebaseAuth.instance
        .linkWithCredential(
            EmailAuthProvider.getCredential(email: _email, password: _password))
        .then((user) {
      uploadImages(); //only upload image and set information into firestore if email credentials are valid
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }).catchError((PlatformException e) {
      if (e.code == "ERROR_PROVIDER_ALREADY_LINKED" ||
          e.code == "ERROR_CREDENTIAL_ALREADY_IN_USE") {
        print(e);
        _showSnackBar("Email is already in use!");
      } else if (e.code == "ERROR_REQUIRES_RECENT_LOGIN") {
        print(e);
        verifyPhone();
      } else {
        print(e);
      }
    });
  }

  //Pre-condition: Called only when _image has been sethg
  //uploading profileImage and thumbnailImage to firebase
  void uploadImages() {
    String uid;
    FirebaseAuth.instance.currentUser().then((user) {
      uid = user.uid;
      final StorageReference profileRef =
          FirebaseStorage.instance.ref().child('user/${uid}/profileImage.jpg');
      final StorageReference thumbnailRef = FirebaseStorage.instance
          .ref()
          .child('user/${uid}/thumbnailImage.jpg');

      final StorageUploadTask profileTask = profileRef.putFile(_image);
      final StorageUploadTask thumbnailTask = thumbnailRef.putFile(_thumbnail);
      profileTask.onComplete.then((profVal) {
        profVal.ref.getDownloadURL().then((profileLink) {
          thumbnailTask.onComplete.then((thumbnailRef) {
            thumbnailRef.ref.getDownloadURL().then((thumbnailLink) {
              FirebaseAuth.instance.currentUser().then((user) {
                ConfigHelper.instance.currentUserProperty.value.setUser(
                    _email,
                    0,
                    0,
                    profileLink,
                    _name,
                    user.metadata.creationTimestamp,
                    user.metadata.lastSignInTimestamp,
                    thumbnailLink,
                    _phoneNumber);
              }).catchError((e) {
                print(e);
              });
            }).catchError((e) {
              print(e);
            });
          }).catchError((e) {
            print(e);
          });
        }).catchError((e) {
          print(e);
        });
      }).catchError((e) {
        print(e);
      });
    }).catchError((e) {
      print(e);
    });
  }

  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////

  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      content: new Text(message),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  //to raise the bottom sheet
  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Please select your source:',
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  getImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('Photos'),
                onTap: () {
                  Navigator.of(context).pop();

                  getImageFromGallery();
                },
              ),
              ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Cancel'),
                  onTap: () {
                    Navigator.of(context).pop();
                  }),
              SizedBox(
                height: 20,
              ),
            ],
          );
        });
  }

  void _validate() {
    final form = _formKey.currentState;
    if (form.validate()) {
      // Text forms was validated.
      form.save();
      createProfile();
    } else {
      setState(() => _autoValidate = true);
    }
  }

  String _validateName(String value) {
    if (value.isEmpty) {
      return "Enter your name";
    }
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return "Enter your password";
    } else if (value.length < 7) {
      return "Password must be at least 7 characters long";
    }
  }

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
    return 'Pleas enter a valid email address';
  }

  ///////////////////////////////////////////////////////////////////////////////
  //TO BUILD THE SCREEN//////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
  //This builds the user interface on the screen
  //Not written in build so that it can be wrapped with modal_progress_HUD
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: ListView(
              children: [
                GestureDetector(
                  //onTap: getImage,
                  onTap: _showModalSheet,

                  child: _image == null
                      ? Container(
                          height: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Icon(Icons.add_a_photo, size: 100.0),
                          ),
                          color: ColorHelper.dabaoGreyE0,
                        )
                      : Image.file(
                          _image,
                          height: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill,
                        ),
                ),
                SizedBox(height: 50.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(children: <Widget>[
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: _phoneNumber,
                      ),
                    ),
                    TextFormField(
                      onSaved: (value) {
                        _name = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                      validator: _validateName,
                    ),
                    TextFormField(
                      onSaved: (value) {
                        _email = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                      ),
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    Container(
                        child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            onSaved: (value) {
                              _password = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: passwordVisibility,
                            validator: _validatePassword,
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              if (passwordVisibility == false) {
                                setState(() {
                                  passwordVisibility = true;
                                });
                              } else {
                                setState(() {
                                  passwordVisibility = false;
                                });
                              }
                            },
                            child: passwordVisibility == true
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off)),
                      ],
                    )),
                    SizedBox(height: 50.0),
                    RaisedButton(
                        child: Container(
                          height: 40,
                          child: Center(
                            child: Text('Logout'),
                          ),
                        ),
                        color: ColorHelper.dabaoGreyE0,
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        }),
                    RaisedButton(
                        child: Container(
                          height: 40,
                          child: Center(
                            child: Text('Create Profile'),
                          ),
                        ),
                        color: ColorHelper.dabaoOrange,
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        onPressed: _validate),

                    /* For testing purposes
                  RaisedButton(
                  child: Container(
                    height: 40,
                    child: Center(
                      child: Text('Test printing out phone number'),
                    ),
                  ),
                  color: ColorHelper.dabaoGreyE0,
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.currentUser().then((user) {
                      print(user.email);
                      print(user.phoneNumber);
                    });
                  }),*/
                  ]),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    //ModalProgressHUD is a widget. It takes in a widget as child, and variable used for AsyncCall
    return ModalProgressHUD(
        child: buildWidget(context), inAsyncCall: _inProgress);
  }
}
