import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_indicators/progress_indicators.dart';

class Personal extends StatefulWidget {
  @override
  _PersonalState createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  MutableProperty<User> currentUser = ConfigHelper.instance.currentUserProperty;

  //temp image
  File _image;

  //temp thumbnail

  //Toggle between TextFormField and Text
  bool updateFlag;

  final _nameTextController = TextEditingController();

  final _scrollController = ScrollController();

  void initState() {
    super.initState();
    updateFlag = false;
  }

  @override
  void dispose() {
    _image = null;
    _nameTextController.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0.0,
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return Align(
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    updateFlag ? 'Save' : 'Edit Profile',
                    style: FontHelper.regular14Black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    updateFlag = !updateFlag;
                  });
                  if (updateFlag == false) {
                    _update(context);
                    _uploadImages(context);
                  }
                },
              ),
            );
          })
        ],
      ),
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          controller: _scrollController,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildUser(),
              ],
            ),
            _buildRatingCard(),
            _buildDetailsCard(),
            Offstage(
              offstage: !updateFlag,
              child: Container(
                  child: Text(
                "Tap on any field to change your details, don't forget to save changes!",
                style: FontHelper.semiBold10Grey,
                textAlign: TextAlign.center,
                softWrap: true,
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUser() {
    return Column(
      children: <Widget>[
        StreamBuilder<String>(
            stream: currentUser.producer.value.thumbnailImage,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null)
                return FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(
                          'assets/icons/profile_icon.png',
                          fit: BoxFit.fill,
                        )),
                  ),
                );
              else
                return Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: <Widget>[
                    FittedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data,
                            placeholder: GlowingProgressIndicator(
                              child: Icon(
                                Icons.image,
                                size: 100,
                              ),
                            ),
                            errorWidget: Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Offstage(
                            offstage: !updateFlag,
                            child: GestureDetector(
                              onTap: () {
                                if (updateFlag == true)
                                  _updatePhotoOptionsBottomModal();
                              },
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                                child: Container(
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF707070).withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FittedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: _image == null
                              ? Offstage()
                              : Image.file(
                                  _image,
                                  height: MediaQuery.of(context).size.width,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                    ),
                  ],
                );
            }),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<String>(
              stream: currentUser.producer.value.name,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null)
                  return Offstage();
                return Text(
                  snapshot.data != null ? snapshot.data : '',
                  style: FontHelper.semiBold20Black,
                );
              }),
        ),
      ],
    );
  }

  Widget _buildRatingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(11.0),
      color: Colors.white,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<int>(
                  stream: currentUser.producer.value.completedOrders,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Column(
                        children: <Widget>[
                          Text(
                            "0",
                            style: FontHelper.semiBold20Black,
                          ),
                          Text(
                            'Completed\nOrders',
                            style: FontHelper.regular11Black,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    print('Completed Orders: ${snapshot.data.toString()}');
                    return Column(
                      children: <Widget>[
                        Text(
                          snapshot.data.toString(),
                          style: FontHelper.semiBold20Black,
                        ),
                        Text(
                          'Completed\nOrders',
                          style: FontHelper.regular11Black,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
            ),
            Container(
              height: 60,
              width: 1.0,
              color: Color(0x11000000),
            ),
            Expanded(
              child: StreamBuilder<int>(
                  stream: currentUser.producer.value.completedDeliveries,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Column(
                        children: <Widget>[
                          Text(
                            "0",
                            style: FontHelper.semiBold20Black,
                          ),
                          Text(
                            'Completed\DDeliveries',
                            style: FontHelper.regular11Black,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    print('Completed Deliveries: ${snapshot.data.toString()}');
                    return Column(
                      children: <Widget>[
                        Text(
                          snapshot.data.toString(),
                          style: FontHelper.semiBold20Black,
                        ),
                        Text(
                          'Completed\nDeliveries',
                          style: FontHelper.regular11Black,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
            ),
            Container(
              height: 60,
              width: 1.0,
              color: Color(0x11000000),
            ),
            Expanded(
              child: StreamBuilder<double>(
                  stream: currentUser.producer.value.rating,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "0",
                                style: FontHelper.semiBold20Black,
                              ),
                              Image.asset('assets/icons/yellow_star.png')
                            ],
                          ),
                          Text(
                            'Rating',
                            style: FontHelper.regular11Black,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    print('Rating: ${snapshot.data.toString()}');
                    return Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              snapshot.data.toString(),
                              style: FontHelper.semiBold20Black,
                            ),
                            Image.asset('assets/icons/yellow_star.png')
                          ],
                        ),
                        Text(
                          'Rating',
                          style: FontHelper.regular11Black,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(11.0),
      color: Colors.white,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                'Full Name',
                style: FontHelper.regular10lightgrey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: StreamBuilder<String>(
                  stream: currentUser.producer.value.name,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Offstage();
                    if (updateFlag) {
                      _nameTextController.text = snapshot.data;
                      return TextFormField(
                        controller: _nameTextController,
                        style: FontHelper.regular12Black,
                        onSaved: (input) {
                          _nameTextController.text = input;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(0),
                        ),
                      );
                    }
                    return Text(
                      snapshot.data != null ? snapshot.data : '',
                      style: FontHelper.regular12Black,
                    );
                  }),
            ),
            Container(
              height: 1.0,
              width: 1000,
              color: Color(0x11000000),
            ),
            updateFlag
                ? Offstage()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      'Phone Number',
                      style: FontHelper.regular10lightgrey,
                    ),
                  ),
            updateFlag
                ? Offstage()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: StreamBuilder<String>(
                        stream: currentUser.producer.value.handPhone,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null)
                            return Offstage();

                          return Text(
                            snapshot.data != null ? snapshot.data : '',
                            style: FontHelper.regular12Black,
                          );
                        }),
                  ),
            updateFlag
                ? Offstage()
                : Container(
                    height: 1.0,
                    width: 1000,
                    color: Color(0x11000000),
                  ),
            updateFlag
                ? Offstage()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      'Email Address',
                      style: FontHelper.regular10lightgrey,
                    ),
                  ),
            updateFlag
                ? Offstage()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: StreamBuilder<String>(
                        stream: currentUser.producer.value.email,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null)
                            return Offstage();
                          return Text(
                            snapshot.data != null ? snapshot.data : '',
                            style: FontHelper.regular12Black,
                          );
                        }),
                  ),
          ],
        ),
      ),
    );
  }

  Future _update(BuildContext context) async {
    if (_nameTextController.text != '') {

      ConfigHelper.instance.currentUserProperty.value.setName(_nameTextController.text);
      
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in the blank(s)'),
      ));
    }
  }

  Future _updatePhotoOptionsBottomModal() async {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            color: Colors.white,
            child: SafeArea(
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
            ),
          );
        });
  }

  //get image
  void getImage(ImageSource imageSource) {
    ImagePicker.pickImage(source: imageSource).then((image) {
      if (image == null) {
      } else {
        //give user the cropping option
        return _cropImage(image);
      }
    }).then((croppedImage) {
      setState(() {
        if (croppedImage != null) {
          _image = croppedImage;
        }
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      toolbarColor: ColorHelper.dabaoOrange,
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    return croppedFile;
  }

  // void creatingThumbnail() {
  //   getTemporaryDirectory().then((tempDir) {
  //     String tempPath = tempDir.path;
  //     Resize.Image resizedImage = Resize.decodeImage(_image.readAsBytesSync());
  //     Resize.Image thumbnail = Resize.copyResize(resizedImage, 100, 100);
  //     var thumbnailImage = new File(tempPath + 'thumbnailImage.png')
  //       ..writeAsBytesSync(Resize.encodePng(thumbnail));
  //     _thumbnail = thumbnailImage;
  //   });
  // }

  //Uploading profileImage and thumbnailImage to firebase storage and updating user database
  Future _uploadImages(context) async {
    if (_image != null) {
      final StorageReference profileRef = FirebaseStorage.instance
          .ref()
          .child('users/${currentUser.value.uid}/profileImage.jpg');

      final StorageUploadTask profileTask = profileRef.putFile(_image,StorageMetadata(contentType: 'image/jpeg'));

      profileTask.onComplete.then((profVal) {
        profVal.ref.getDownloadURL().then((profileLink) {
          if (profileLink != null && profileLink != '') {
            ConfigHelper.instance.currentUserProperty.value.setProfileImage(profileLink);
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Please try again'),
            ));
          }
        });
      });
    }
  }
}
