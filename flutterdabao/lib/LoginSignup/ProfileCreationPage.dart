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
                  textCapitalization: TextCapitalization.words,
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

  //Pre-condition: Called only when _image has been set
  void creatingThumbnail(File image) async {
    print("Creating Thumbnail");
    await getTemporaryDirectory().then((tempDir) async {
      print("tempDir " + tempDir.path);
      String tempPath = tempDir.path;

      List<int> data = await image.readAsBytes();
      print("imaged readAsBytes ");

      Resize.Image resizedImage = Resize.decodeImage(data);
      print("imaged Resized ");

      // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
      Resize.Image thumbnail = Resize.copyResize(resizedImage, 100, 100);
      print("thumbnail Resized ");

      // Save the thumbnail as a PNG.
      var thumbnailImage = new File(tempPath + 'thumbnailImage.png')
        ..writeAsBytesSync(Resize.encodePng(thumbnail));

      print("thumbnail saved ");

      _thumbnail = thumbnailImage;
      setState(() {
        _image = image;
        _inProgress = false;
      });
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

  //get image
  void getImage(ImageSource imageSource) async {
    setState(() {
      _inProgress = true;
    });

    await ImagePicker.pickImage(source: imageSource).then((image) async {
      if (image == null) {
        setState(() {
          _inProgress = false;
        });
      } else {
        //give user the cropping option
        var croppedImage = await _cropImage(image);

        if (croppedImage == null) {
          setState(() {
            _inProgress = false;
          });
        } else {
          creatingThumbnail(croppedImage);
        }
      }
    }).catchError((e) {
      print(e);
      setState(() {
        _inProgress = false;
      });
    });
    // regardless what happens, _inprogess will be false at the end of this
    setState(() {
      _inProgress = false;
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
    if (_image != null &&
        _nameController.text != null &&
        _nameController.text != '') {
      uploadImages();
      print('Uploaded successfully');
    }
  }

  void uploadImages() {
    setState(() {
      _inProgress = true;
    });

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
                    getImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_album),
                  title: Text('Photos'),
                  onTap: () {
                    Navigator.of(context).pop();

                    getImage(ImageSource.gallery);
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

  // ///////////////////////////////////////////////////////////////////////////////
  // //TO BUILD THE SCREEN//////////////////////////////////////////////////////////
  // ///////////////////////////////////////////////////////////////////////////////
  // //This builds the user interface on the screen
  // //Not written in build so that it can be wrapped with modal_progress_HUD
  // Widget buildWidget(BuildContext context) {
  //   return Scaffold(
  //       body: SafeArea(
  //     child: Form(
  //       autovalidate: _autoValidate,
  //       child: ListView(
  //         children: [
  //           GestureDetector(
  //             //onTap: getImage,
  //             onTap: _showModalSheet,

  //             child: _image == null
  //                 ? Container(
  //                     height: MediaQuery.of(context).size.width,
  //                     width: MediaQuery.of(context).size.width,
  //                     child: Center(
  //                       child: Icon(Icons.add_a_photo, size: 100.0),
  //                     ),
  //                     color: ColorHelper.dabaoGreyE0,
  //                   )
  //                 : Image.file(
  //                     _image,
  //                     height: MediaQuery.of(context).size.width,
  //                     width: MediaQuery.of(context).size.width,
  //                     fit: BoxFit.fill,
  //                   ),
  //           ),
  //           SizedBox(height: 50.0),
  //           Container(
  //             padding: EdgeInsets.symmetric(horizontal: 24.0),
  //             child: Column(children: <Widget>[
  //               TextFormField(
  //                 textCapitalization: TextCapitalization.words,
  //                 controller: _nameController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Name',
  //                 ),
  //                 validator: _validateName,
  //               ),
  //               SizedBox(height: 50.0),
  //               RaisedButton(
  //                 child: Container(
  //                   height: 40,
  //                   child: Center(
  //                     child: Text('Create Profile'),
  //                   ),
  //                 ),
  //                 color: ColorHelper.dabaoOrange,
  //                 elevation: 5.0,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.all(Radius.circular(5.0)),
  //                 ),
  //                 onPressed: createProfile,
  //               )
  //             ]),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ));
  // }

  // @override
  // Widget build(BuildContext context) {
  //   //ModalProgressHUD is a widget. It takes in a widget as child, and variable used for AsyncCall
  //   return ModalProgressHUD(
  //       child: buildWidget(context), inAsyncCall: _inProgress);
  // }
}
