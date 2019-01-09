import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:image/image.dart' as Resize;
import 'package:path_provider/path_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileCreationPage extends StatefulWidget {
  final VoidCallback onCompleteCallback;

  const ProfileCreationPage({Key key, this.onCompleteCallback})
      : super(key: key);
  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _nameController = TextEditingController();
  File _image;
  File _thumbnail;

  //for loading spinner, appears if true, hidden if false
  //to activate for loading spinner
  bool _inProgress = false;
  bool _autoValidate = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: buildWidget(context), inAsyncCall: _inProgress);
  }

  Widget buildWidget(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Form(
        autovalidate: _autoValidate,
        child: ListView(
          children: [
            GestureDetector(
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: _validateName,
                ),
                SizedBox(height: 50.0),
                Builder(builder: (BuildContext context) {
                  return RaisedButton(
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
                    onPressed: () {
                      createProfile(context);
                    },
                  );
                })
              ]),
            ),
          ],
        ),
      ),
    ));
  }

  void creatingThumbnail() {
    getTemporaryDirectory().then((tempDir) {
      String tempPath = tempDir.path;
      Resize.Image resizedImage = Resize.decodeImage(_image.readAsBytesSync());
      Resize.Image thumbnail = Resize.copyResize(resizedImage, 100, 100);
      var thumbnailImage = new File(tempPath + 'thumbnailImage.png')
        ..writeAsBytesSync(Resize.encodePng(thumbnail));
      _thumbnail = thumbnailImage;
    });
  }

  void getImageFromCamera() async {
    ImagePicker.pickImage(source: ImageSource.camera).then((image) async {
      if (image == null) {
      } else {
        var croppedImage = await _cropImage(image);
        setState(() {
          _image = croppedImage;
        });
        creatingThumbnail();
      }
    }).catchError((e) {
      print(e);
    });
  }

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

  void getImageFromGallery() async {
    ImagePicker.pickImage(source: ImageSource.gallery).then((image) async {
      if (image == null) {
      } else {
        var croppedImage = await _cropImage(image);
        setState(() {
          _image = croppedImage;
        });
        creatingThumbnail();
      }
    });
  }

  void createProfile(BuildContext context) {
    if (_image == null) {
      _showSnackBar(context, "Please upload a profile image");
      print('no picture');
      return;
    }
    if (_nameController.text == null || _nameController.text == '') {
      _showSnackBar(context, "Please input a profile name");
      print('no name');
      return;
    }
    if (_image != null && _nameController.text != null && _nameController.text != '') {
      uploadImages();
      print('Uploaded successfully');
    }
  }

  void uploadImages() {
    String uid;
    FirebaseAuth.instance.currentUser().then((user) {
      uid = user.uid;
      final StorageReference profileRef =
          FirebaseStorage.instance.ref().child('user/$uid/profileImage.jpg');
      final StorageReference thumbnailRef =
          FirebaseStorage.instance.ref().child('user/$uid/thumbnailImage.jpg');

      final StorageUploadTask profileTask = profileRef.putFile(_image);
      final StorageUploadTask thumbnailTask = thumbnailRef.putFile(_thumbnail);
      profileTask.onComplete.then((profVal) {
        profVal.ref.getDownloadURL().then((profileLink) {
          thumbnailTask.onComplete.then((thumbnailRef) {
            thumbnailRef.ref.getDownloadURL().then((thumbnailLink) {
              FirebaseAuth.instance.currentUser().then((user) {
                ConfigHelper.instance.currentUserProperty.value.setUser(
                  profileLink,
                  _nameController.text,
                  DateTime.fromMillisecondsSinceEpoch(
                      user.metadata.creationTimestamp),
                  DateTime.fromMillisecondsSinceEpoch(
                      user.metadata.lastSignInTimestamp),
                  thumbnailLink,
                );
                widget.onCompleteCallback();
              }).catchError((e) {
                setState(() {
                  _inProgress = false;
                });
                print(e);
              });
            }).catchError((e) {
              setState(() {
                _inProgress = false;
              });
              print(e);
            });
          }).catchError((e) {
            setState(() {
              _inProgress = false;
            });
            print(e);
          });
        }).catchError((e) {
          setState(() {
            _inProgress = false;
          });
          print(e);
        });
      }).catchError((e) {
        setState(() {
          _inProgress = false;
        });
        print(e);
      });
    }).catchError((e) {
      setState(() {
        _inProgress = false;
      });
      print(e);
    });
  }

  void _showSnackBar(BuildContext context, message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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
              ],
            ),
          );
        });
  }

  String _validateName(value) {
    if (value.isEmpty) {
      return "Enter your name";
    }
    return "Please try again";
  }
}
