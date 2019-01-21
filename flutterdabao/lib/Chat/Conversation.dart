import 'dart:io';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/Chat/CounterOfferOverlay.dart';
import 'package:flutterdabao/CustomWidget/ExpansionTile.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMaps.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:flutterdabao/Model/Message.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/OrderWidget/OneCard.dart';
import 'package:flutterdabao/OrderWidget/StatusColor.dart';
import 'package:flutterdabao/Profile/ViewProfile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart' as Rxdart;
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
import 'dart:convert';

GlobalKey<ConversationState> currentKey;

getCurrentKey() {
  return currentKey;
}

class Conversation extends StatefulWidget {
  final Channel channel;
  final LatLng location;

  Conversation({@required Key key, @required this.channel, this.location})
      : super(key: key) {
    currentKey = key;
  }

  ConversationState createState() => ConversationState();
}

class ConversationState extends State<Conversation>
    with HavingSubscriptionMixin {
  MutableProperty<Order> order = MutableProperty(null);
  MutableProperty<List<Message>> listOfMessages = MutableProperty(List());
  // MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  //text input properties in textfield
  TextEditingController _textController;

  //textfield on tap
  FocusNode _myFocusNode;

  //scroll properties in the listview
  ScrollController _scrollController;

  //expansion of whole card
  bool expandFlag = false;
  bool forceCloseFlag = false;

  //expansion of location description only
  bool expansionFlag = false;

  //expansion of location description only
  // bool isTouchDown;

  //initial position of vertical scroll
  double initial;

  //upload image as message
  File _image;

  //control color of send button
  bool sendButtonFlag;

  Color colorStatus = ColorHelper.dabaoOrange;

  ConversationState() {
    // isTouchDown = false;
    sendButtonFlag = false;
  }
  KeyboardVisibilityNotification _keyboardVisibility =
      new KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId;

  @override
  void initState() {
    super.initState();

    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        print("testing keyboard");
        setState(() {
          forceCloseFlag = visible;
          expandFlag = false;

        });
      },
    );

    _myFocusNode = FocusNode();
    _myFocusNode.addListener(_keyboardListener);
    _textController = TextEditingController();
    _scrollController = ScrollController();

    listOfMessages = widget.channel.listOfMessages;

    subscription.add(order.bindTo(widget.channel.orderUid
        .where((uid) => uid != null)
        .map((uid) => Order.fromUID(uid))));
  }

  @override
  void dispose() {
    disposeAndReset();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    widget.channel.markAsRead();
    currentKey = null;
    _myFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _keyboardListener() {
    if (_myFocusNode.hasFocus) {
      setState(() {
        forceCloseFlag = true;
        expandFlag = true;
      });
    } else {
      setState(() {
        forceCloseFlag = false;
        expandFlag = false;
      });
    }
  }

  bool _userStoppedScrolling(
      Notification notification, ScrollController scrollController) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity;
  }

  bool _scrollListener(Notification notification) {
    if (!_userStoppedScrolling(notification, _scrollController)) {
      if (_scrollController.offset > initial) {
        setState(() {
          expandFlag = false;
        });
      }
      if (_scrollController.offset < initial) {
        setState(() {
          expandFlag = true;
        });
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          print("testing it came here ");
          setState(() {
            forceCloseFlag = false;
          });
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                size: 26,
                color: Colors.black,
              ),
            ),
            elevation: 0.0,
            title: _buildU(),
          ),
          body: _buildB(),
        ));
  }

  Widget _buildU() {
    return StreamBuilder(
        stream: order.producer,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (!snapshot.hasData) return Offstage();
          return _buildUser();
        });
  }

  Widget _buildUser() {
    return StreamBuilder<User>(
      stream: Rxdart.Observable.combineLatest2<List<String>, User, User>(
          widget.channel.participantsID,
          ConfigHelper.instance.currentUserProperty.producer,
          (participantsID, currentUser) {
        List tempID = List.from(participantsID);
        if (tempID == null || currentUser == null) {
          return null;
        }
        tempID.remove(currentUser.uid);

        if (tempID.length == 0) {
          return null;
        }

        return User.fromUID(tempID.first);
      }),
      builder: (context, user) {
        if (!user.hasData || user == null) return Offstage();
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              FadeRoute(
                  widget: ViewProfile(
                currentUser: user,
              )),
            );
          },
          child: Row(
            children: <Widget>[
              StreamBuilder<String>(
                stream: user.data.thumbnailImage,
                builder: (context, user) {
                  if (!user.hasData) return Offstage();
                  return FittedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CachedNetworkImage(
                          imageUrl: user.data,
                          placeholder: GlowingProgressIndicator(
                            child: Icon(
                              Icons.account_circle,
                              size: 30,
                            ),
                          ),
                          errorWidget: Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                width: 10,
              ),
              StreamBuilder<String>(
                stream: user.data.name,
                builder: (context, user) {
                  if (!user.hasData) return Offstage();
                  return Text(
                    user.hasData ? user.data : "Error",
                    style: FontHelper.semiBold16Black,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildB() {
    return _buildBody();
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        StreamBuilder<bool>(stream: order.producer.switchMap((order) {
          if (order == null) return null;
          return Rxdart.Observable.combineLatest2<User, String, bool>(
              ConfigHelper.instance.currentUserProperty.producer, order.creator,
              (user, creatorID) {
            if (user == null || creatorID == null) {
              return null;
            }

            return user.uid == creatorID;
          });
        }), builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) return Offstage();
          if (snapshot.data)
            return Padding(
              padding: const EdgeInsets.all(11.0),
              child: Text(
                'You are chatting about your order:',
                style: FontHelper.regular15LightGrey,
              ),
            );
          else
            return Padding(
                padding: const EdgeInsets.all(11.0),
                child: StreamBuilder<User>(
                  stream: Rxdart.Observable.combineLatest2<List<String>, User,
                          User>(widget.channel.participantsID,
                      ConfigHelper.instance.currentUserProperty.producer,
                      (participantsID, currentUser) {
                    List tempID = List.from(participantsID);
                    if (tempID == null || currentUser == null) {
                      return null;
                    }
                    tempID.remove(currentUser.uid);

                    if (tempID.length == 0) {
                      return null;
                    }

                    return User.fromUID(tempID.first);
                  }),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.data == null) return Offstage();

                    return StreamBuilder(
                      stream: snapshot.data.name,
                      builder: (context, snap) {
                        if (snapshot.data == null) return Offstage();
                        return Text(
                          'You are chatting about ${snap.data}\'s order:',
                          overflow: TextOverflow.ellipsis,
                          style: FontHelper.regular15LightGrey,
                        );
                      },
                    );
                  },
                ));
        }),
        OneCard(
          expandFlag: expandFlag || forceCloseFlag,
          channel: widget.channel,
          location: widget.location,
        ),
        _buildMessages(),
        _buildInput(),
      ],
    );
  }

  Widget _buildMessages() {
    return Expanded(
      child: StreamBuilder<List<Message>>(
        stream: listOfMessages.producer.map((data) {
          List<Message> temp = List<Message>();

          data.forEach((element) {
            temp.add(element);
          });
          temp.sort((a, b) => b.timestamp.value.compareTo(a.timestamp.value));
          return temp.toList();
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Offstage();
          return GestureDetector(
              onTap: () {
                if (_myFocusNode.hasFocus) {
                  _myFocusNode.unfocus();
                  setState(() {
                    expandFlag = false;
                  });
                }
              },
              onPanDown: (_) {
                initial = _scrollController.position.pixels;
              },
              child: new NotificationListener(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) {
                    return _buildChatBox(index, snapshot.data[index]);
                  },
                  itemCount: snapshot.data.length,
                ),
                onNotification: _scrollListener,
              ));
        },
      ),
    );
  }

  Widget _buildChatBox(index, Message data) {
    if (data.message.value == null && data.imageUrl.value != null) {
      //query images
      if (data.sender.value ==
          ConfigHelper.instance.currentUserProperty.value.uid) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            buildMessgeDate(data),
            buildMessageImage(data),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildSenderImage(data),
            buildMessageImage(data),
            buildMessgeDate(data),
          ],
        );
      }
    } else {
      //query messages
      if (data.sender.value ==
          ConfigHelper.instance.currentUserProperty.value.uid) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            buildMessgeDate(data),
            buildMessageMessage(data),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildSenderImage(data),
            buildMessageMessage(data),
            buildMessgeDate(data),
          ],
        );
      }
    }
  }

  Flexible buildMessageMessage(Message data) {
    return Flexible(
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: EdgeInsets.all(9),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: data.sender.value ==
                    ConfigHelper.instance.currentUserProperty.value.uid
                ? ColorHelper.dabaoPaleOrange
                : ColorHelper.dabaoGreyE0,
            borderRadius: BorderRadius.circular(10)),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: <Widget>[
            Text(data.message.value),
            Text(
              DateTimeHelper.convertDateTimeToAMPM(data.timestamp.value),
              style: FontHelper.smallTimeTextStyle,
            )
          ],
        ),
      ),
    );
  }

  StreamBuilder<User> buildSenderImage(Message data) {
    return StreamBuilder<User>(
      stream: data.sender.where((uid) => uid != null).map(
            (uid) => User.fromUID(uid),
          ),
      builder: (context, user) {
        if (!user.hasData) return Offstage();
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              FadeRoute(
                  widget: ViewProfile(
                currentUser: user,
              )),
            );
          },
          child: Row(
            children: <Widget>[
              StreamBuilder<String>(
                stream: user.data.thumbnailImage,
                builder: (context, user) {
                  if (!user.hasData) return Offstage();
                  return FittedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CachedNetworkImage(
                          imageUrl: user.data,
                          placeholder: GlowingProgressIndicator(
                            child: Icon(
                              Icons.account_circle,
                              size: 30,
                            ),
                          ),
                          errorWidget: Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Container buildMessageImage(Message data) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
      margin: EdgeInsets.fromLTRB(5, 5, 12, 5),
      child: Wrap(
        alignment: data.sender.value ==
                ConfigHelper.instance.currentUserProperty.value.uid
            ? WrapAlignment.end
            : WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: <Widget>[
          GestureDetector(
            child: CachedNetworkImage(
              imageUrl: data.imageUrl.value,
              placeholder: GlowingProgressIndicator(
                child: Icon(
                  Icons.image,
                  size: 30,
                ),
              ),
              errorWidget: Icon(Icons.account_circle),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                            appBar: AppBar(
                              title: Text("Photo"),
                            ),
                            body: HeroPhotoViewWrapper(
                              backgroundDecoration: BoxDecoration(
                                  color: ColorHelper.dabaoOffWhiteF5),
                              tag: data.imageUrl.value,
                              imageProvider: NetworkImage(data.imageUrl.value),
                            ),
                          )));
            },
          ),
          Text(
            DateTimeHelper.convertDateTimeToAMPM(data.timestamp.value),
            style: FontHelper.smallTimeTextStyle,
          )
        ],
      ),
    );
  }

  Widget buildMessgeDate(Message data) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          DateTimeHelper.convertDateTimeToDate(data.timestamp.value),
          style: FontHelper.smallTimeTextStyle,
        ),
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          _buildCounterOfferReply(),
          Line(),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                    child: GestureDetector(
                  onTap: _updatePhotoOptionsBottomModal,
                  child: Icon(Icons.add),
                )),
                Expanded(
                    flex: 5,
                    child: TextField(
                      onChanged: (typedText) {
                        if (_textController.text.length > 0) {
                          setState(() {
                            sendButtonFlag = true;
                          });
                        } else {
                          setState(() {
                            sendButtonFlag = false;
                          });
                        }
                      },
                      focusNode: _myFocusNode,
                      onTap: () {
                        setState(() {
                          expandFlag = true;
                        });
                      },
                      onSubmitted: (_) {
                        setState(() {
                          expandFlag = false;
                        });
                      },
                      textCapitalization: TextCapitalization.sentences,
                      controller: _textController,
                      style: TextStyle(height: 1, color: Colors.black),
                      decoration: const InputDecoration(
                          hintStyle: FontHelper.regular15Grey,
                          hintText: "Enter your message",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)))),
                    )),
                Expanded(
                    child: Center(
                        child: GestureDetector(
                  onTap: () {
                    if (_textController.text != '') {
                      widget.channel.addMessage(
                          _textController.text,
                          ConfigHelper.instance.currentUserProperty.value.uid,
                          null);
                      setState(() {
                        sendButtonFlag = false;
                      });
                      _textController.clear();
                      _scrollController.animateTo(0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                  child: Container(
                      padding: EdgeInsets.fromLTRB(10, 8, 8, 8),
                      decoration: BoxDecoration(
                          boxShadow: sendButtonFlag
                              ? [
                                  BoxShadow(
                                    color: Color.fromRGBO(0xFC, 0x96, 0x67, 1),
                                    offset: new Offset(0.0, 2.0),
                                    blurRadius: 5.0,
                                  )
                                ]
                              : [],
                          shape: BoxShape.circle,
                          color: sendButtonFlag
                              ? ColorHelper.dabaoOrange
                              : ColorHelper.dabaoOffGreyD3),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      )),
                )))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterOfferReply() {
    return StreamBuilder<bool>(
      stream: Rxdart.Observable.combineLatest2<String, User, bool>(
          order.producer
              .switchMap((order) =>
                  order == null ? Rxdart.Observable.just(null) : order.creator)
              .map((creatorID) {
            if (creatorID == null) return null;

            return creatorID;
          }),
          ConfigHelper.instance.currentUserProperty.producer,
          (orderUserID, currentUser) {
        if (orderUserID == null || currentUser == null)
          return false;
        else
          return orderUserID == currentUser.uid;
      }),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null || !snapshot.data)
          return Offstage();

        return StreamBuilder<CounterOffer>(
          stream: widget.channel.counterOffer,
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data.status != CounterOffer.counterOffStatus_Open)
              return Offstage();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Line(
                  margin: EdgeInsets.only(bottom: 10.0),
                ),
                Text(
                  "Offered to pick up for ${StringHelper.doubleToPriceString(snapshot.data.price)}",
                  style: FontHelper.regular12Black,
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      color: Colors.white,
                      child: Icon(
                        Icons.check,
                        color: ColorHelper.dabaoOrange,
                      ),
                      onPressed: () async {
                        showLoadingOverlay(context: context);

                        await FirebaseCloudFunctions.acceptOrder(
                            deliveryFee: snapshot.data.price,
                            orderID: order.value.uid,
                            acceptorID: snapshot.data.offererID,
                            deliveryTime:
                                DateTimeHelper.convertDateTimeToString(
                              snapshot.data.deliveryTime,
                            )).then((isSuccessful) {
                          if (isSuccessful) {
                            Navigator.of(context).pop();
                            widget.channel.accept();
                            widget.channel.addMessage(
                                ConfigHelper.instance.currentUserProperty.value
                                        .name.value +
                                    " has accepted the offer",
                                ConfigHelper
                                    .instance.currentUserProperty.value.uid,
                                null);
                          } else {
                            Navigator.of(context).pop();
                            final snackBar = SnackBar(
                                content: Text(
                                    'An Error has occured. Please check your network connectivity'));
                            Scaffold.of(context).showSnackBar(snackBar);
                          }
                        }).catchError((error) {
                          if (error is PlatformException) {
                            PlatformException e = error;
                            Navigator.of(context).pop();
                            final snackBar = SnackBar(content: Text(e.message));
                            Scaffold.of(context).showSnackBar(snackBar);
                          } else {
                            Navigator.of(context).pop();
                            final snackBar = SnackBar(
                                content: Text(
                                    'An Error has occured. Please check your network connectivity'));
                            Scaffold.of(context).showSnackBar(snackBar);
                          }
                        });
                      },
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Icon(
                        Icons.clear,
                        color: ColorHelper.dabaoErrorRed,
                      ),
                      onPressed: () {
                        widget.channel.reject();
                        widget.channel.addMessage(
                            ConfigHelper.instance.currentUserProperty.value.name
                                    .value +
                                " has rejected the offer",
                            ConfigHelper.instance.currentUserProperty.value.uid,
                            null);
                      },
                    )
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  Future _updatePhotoOptionsBottomModal() async {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SafeArea(
            child: Container(
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
            ),
          );
        });
  }

  generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  void getImageFromCamera() async {
    ImagePicker.pickImage(source: ImageSource.camera).then((image) async {
      if (image != null) {
        _image = await _cropImage(image);
        final StorageReference profileRef = FirebaseStorage.instance
            .ref()
            .child(
                'storage/${ConfigHelper.instance.currentUserProperty.value.uid}/IMG-${formatDate(DateTime.now(), [
              yyyy,
              mm,
              dd
            ])}-DABAO-${generateMd5(_image.toString())}.jpg');

        final StorageUploadTask imageTask = profileRef.putFile(_image);

        imageTask.onComplete.then((result) {
          result.ref.getDownloadURL().then((url) {
            widget.channel.addMessage(
                null, ConfigHelper.instance.currentUserProperty.value.uid, url);
          });
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  void getImageFromGallery() async {
    ImagePicker.pickImage(source: ImageSource.gallery).then((image) async {
      if (image != null) {
        _image = await _cropImage(image);
        final StorageReference profileRef = FirebaseStorage.instance
            .ref()
            .child(
                'storage/${ConfigHelper.instance.currentUserProperty.value.uid}/IMG-${formatDate(DateTime.now(), [
              yyyy,
              mm,
              dd
            ])}-DABAO-${generateMd5(_image.toString())}.jpg');

        final StorageUploadTask imageTask = profileRef.putFile(_image);

        imageTask.onComplete.then((result) {
          result.ref.getDownloadURL().then((url) {
            widget.channel.addMessage(
                null, ConfigHelper.instance.currentUserProperty.value.uid, url);
          });
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      toolbarColor: ColorHelper.dabaoOrange,
      sourcePath: imageFile.path,
      ratioX: 2.0,
      ratioY: 2.0,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    return croppedFile;
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key key, this.photo, this.onTap, this.width})
      : super(key: key);

  final String photo;
  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.asset(
              photo,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class HeroPhotoViewWrapper extends StatelessWidget {
  const HeroPhotoViewWrapper(
      {this.imageProvider,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      this.tag});

  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: PhotoView(
            imageProvider: imageProvider,
            loadingChild: loadingChild,
            backgroundDecoration: backgroundDecoration,
            minScale: minScale,
            maxScale: maxScale,
            heroTag: tag,
          )),
    );
  }
}
