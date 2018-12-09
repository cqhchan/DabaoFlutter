import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _name;
  String _phoneNumber;
  String _email;
  String _password;
  bool passwordVisibility = true;
  String verificationId;
  String smsCode;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _phoneNumber = user.phoneNumber;
      });
    });
  }

  File _image;
  File _thumbnail;
  //for loading spinner, appears if true, hidden if false
  bool _inProgress = false;

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

  //only works if you are creating a new account
  void addEmailCredentials() {
    //FirebaseAuth.instance.crea
    FirebaseAuth.instance
        .linkWithCredential(
            EmailAuthProvider.getCredential(email: _email, password: _password))
        .then((user) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    })
        //EmailAuthProvider.getCredential(email: _email, password: _password))
        .catchError((e) {
      //if it fails, means that the email already existed
      _showSnackBar("Email is already in use!");
      print(e);
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
                    thumbnailLink);
                /*
                //deactivate loading spinner
                setState(() {
                  _inProgress = false;
                });*/
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

  void createProfile() {
    if (_image == null) { //this is to prevent users from creating profile without a profile image
      _showSnackBar("Please upload a profile image");
      return;
    } else if (_email == null) {
      _showSnackBar("Please enter your email");
      return;
    } else if (_password == null) {
      _showSnackBar("Please enter your password");
      return;
    } else if (_name == null) {
      _showSnackBar("Please enter your name");
      return;
    }
    
    //To activate for loading spinner
    setState(() {
      _inProgress = true;
    });

    //upload the original image
    uploadImages();
    addEmailCredentials();

    //Deactivating loading spinner
    setState(() {
      _inProgress = false;
    });
  }

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

  //This builds the user interface on the screen
  //Not written in build so that it can be wrapped with modal_progress_HUD
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
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
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: passwordVisibility,
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
                      onPressed: createProfile),

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
        ));
  }

  @override
  Widget build(BuildContext context) {
    //ModalProgressHUD is a widget. It takes in a widget as child, and variable used for AsyncCall
    return ModalProgressHUD(
        child: buildWidget(context), inAsyncCall: _inProgress);
  }
}
