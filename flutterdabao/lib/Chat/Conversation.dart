import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterdabao/Chat/CounterOfferOverlay.dart';
import 'package:flutterdabao/CustomWidget/ExpansionTile.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMaps.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
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
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart' as Rxdart;

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

  //text input properties in textfield
  TextEditingController _textController;

  //textfield on tap
  FocusNode _myFocusNode;

  //scroll properties in the listview
  ScrollController _scrollController;

  //expansion of whole card
  bool expandFlag = false;

  //expansion of location description only
  bool expansionFlag;

  //expansion of location description only
  bool isTouchDown;

  //initial position of vertical scroll
  double initial;

  //upload image as message
  File _image;

  //control color of send button
  bool sendButtonFlag;

  ConversationState() {
    isTouchDown = false;
    sendButtonFlag = false;
  }

  @override
  void initState() {
    super.initState();

    _myFocusNode = FocusNode();
    _myFocusNode.addListener(_keyboardListener);
    _textController = TextEditingController();
    _scrollController = ScrollController();

    subscription.add(order.bindTo(widget.channel.orderUid
        .where((uid) => uid != null)
        .map((uid) => Order.fromUID(uid))));

  }

  @override
  void dispose() {
    widget.channel.markAsRead();
    currentKey = null;
    _myFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    subscription.dispose();
    super.dispose();
  }

  _keyboardListener() {
    if (_myFocusNode.hasFocus) {
      setState(() {
        expandFlag = true;
      });
    } else {
      setState(() {
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
    // if (notification is ScrollNotification) {
    // ScrollNotification scrollNotification = notification;

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
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
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
    );
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
        return Row(
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
        _buildTop(),
        _buildMessages(),
        _buildInput(),
      ],
    );
  }

  Widget _buildTop() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: const Color(0x11000000),
          offset: new Offset(0.0, 5.0),
          blurRadius: 8.0,
        ),
      ]),
      child: Wrap(
        alignment: WrapAlignment.start,
        children: <Widget>[
          Offstage(
            offstage: expandFlag,
            child: _buildCard(),
          ),
          StreamBuilder<bool>(
            stream:
                Rxdart.Observable.combineLatest3<User, String, String, bool>(
                    ConfigHelper.instance.currentUserProperty.producer,
                    order.producer.switchMap((currentOrder) =>
                        currentOrder == null ? null : currentOrder.creator),
                    order.producer.switchMap((currentOrder) =>
                        currentOrder == null ? null : currentOrder.status),
                    (currentUser, orderUserID, status) {
              if (currentUser == null ||
                  orderUserID == null ||
                  status == null) {
                return false;
              }
              if (status != orderStatus_Requested) {
                return false;
              }

              return currentUser.uid != orderUserID;
            }),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData || !snapshot.data) return Offstage();
              return _buildButtons();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Column(
      children: <Widget>[
        StreamBuilder<bool>(
          stream: order.producer.switchMap((order) {
            if (order == null) return null;

            return Rxdart.Observable.combineLatest2<User, String, bool>(
                ConfigHelper.instance.currentUserProperty.producer,
                order.creator, (user, creatorID) {
              if (user == null || creatorID == null) {
                return null;
              }

              return user.uid == creatorID;
            });
          }),
          builder: (BuildContext context, snapshot) {
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
                child: Text(
                  'You are chatting about the other party order:',
                  style: FontHelper.regular15LightGrey,
                ),
              );
          },
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          margin: EdgeInsets.fromLTRB(11, 0, 11, 11),
          color: Colors.white,
          elevation: 6.0,
          child: Stack(
            children: <Widget>[
              Container(
                height: 9,
                decoration: BoxDecoration(
                  color: ColorHelper.dabaoOrange,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 16, 10, 10),
                child: Wrap(
                  children: <Widget>[
                    StreamBuilder(
                      stream: order.producer.switchMap((order) => order != null
                          ? order.deliveryLocationDescription
                          : Rxdart.Observable.just(null)),
                      builder: (context, snap) {
                        if (!snap.hasData || snap.data == null)
                          return Offstage();
                        return ConfigurableExpansionTile(
                          selectable: order.value,
                          initiallyExpanded: false,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              expansionFlag = order.value.isSelected;
                            });
                          },
                          header: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buildHeader(),
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 50),
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 5,
                                      child: _buildDeliveryPeriod(),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6.0),
                                        child: _buildQuantity(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 17.0,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 50),
                                child: Flex(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  direction: Axis.horizontal,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 2,
                                      ),
                                      child: Container(
                                        height: 30,
                                        child: Image.asset(
                                            "assets/icons/red_marker_icon.png"),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: _buildLocationDescription(),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: _buildTapToLocation(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down)
                            ],
                          ),
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                _buildOrderItems(),
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 50),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: StreamBuilder<String>(
              stream: order.value.foodTag,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    snap.hasData
                        ? StringHelper.upperCaseWords(snap.data)
                        : "Error",
                    style: FontHelper.semiBold16Black,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: StreamBuilder<double>(
              stream: order.value.deliveryFee,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return Text(
                  snap.hasData
                      ? StringHelper.doubleToPriceString(snap.data)
                      : "Error",
                  style: FontHelper.bold16Black,
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPeriod() {
    return StreamBuilder<OrderMode>(
        stream: order.producer
            .switchMap((order) => order == null ? null : order.mode),
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null) return Offstage();
          DateTime startTime;
          DateTime endTime;

          switch (snap.data) {
            case OrderMode.asap:
              startTime = DateTime.now();
              endTime = order.value.endDeliveryTime.value == null
                  ? startTime.add(Duration(minutes: 90))
                  : order.value.endDeliveryTime.value;
              break;
            case OrderMode.scheduled:
              startTime = order.value.startDeliveryTime.value;
              endTime = order.value.endDeliveryTime.value;
              break;
          }

          if (startTime == null || endTime == null) return Offstage();

          if (startTime.isBefore(endTime) || endTime.isBefore(DateTime.now()))
            return Text(
              "Expired",
              style: FontHelper.semiBoldgrey14TextStyle,
              overflow: TextOverflow.ellipsis,
            );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              (startTime.day == DateTime.now().day &&
                      startTime.month == DateTime.now().month &&
                      startTime.year == DateTime.now().year)
                  ? Text(
                      'Today, ' +
                          DateTimeHelper.convertDateTimeToAMPM(startTime) +
                          ' - ' +
                          DateTimeHelper.convertDateTimeToAMPM(endTime),
                      style: FontHelper.semiBoldgrey14TextStyle,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Container(
                      child: Text(
                        snap.hasData
                            ? DateTimeHelper.convertDateTimeToNewLineDate(
                                    startTime) +
                                ', ' +
                                DateTimeHelper.convertDateTimeToAMPM(endTime)
                            : "Error",
                        style: FontHelper.semiBoldgrey14TextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
            ],
          );
        });
  }

  Widget _buildLocationDescription() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCollapsableLocationDescription(),
            StreamBuilder<GeoPoint>(
              stream: order.value.deliveryLocation,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                if (widget.location != null && snap.data != null) {
                  return Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 180),
                    child: Text(
                      snap.hasData
                          ? LocationHelper.calculateDistancFromSelf(
                                      widget.location.latitude,
                                      widget.location.longitude,
                                      snap.data.latitude,
                                      snap.data.longitude)
                                  .toStringAsFixed(1) +
                              'km away'
                          : "?.??km",
                      style: FontHelper.medium12TextStyle,
                    ),
                  );
                } else {
                  return Text(
                    "?.??km",
                    style: FontHelper.medium12TextStyle,
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollapsableLocationDescription() {
    if (!widget.channel.isSelectedProperty.value) {
      return StreamBuilder<String>(
        stream: order.value.deliveryLocationDescription,
        builder: (context, snap) {
          if (!snap.hasData) return Offstage();
          return Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 180,
            ),
            child: Text(
              snap.hasData ? '''${snap.data}''' : "Error",
              style: FontHelper.regular14Black,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      );
    } else {
      return StreamBuilder<String>(
        stream: order.value.deliveryLocationDescription,
        builder: (context, snap) {
          if (!snap.hasData) return Offstage();
          return Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 180,
            ),
            child: Text(
              snap.hasData ? '''${snap.data}''' : "Error",
              style: FontHelper.regular14Black,
            ),
          );
        },
      );
    }
  }

  Widget _buildQuantity() {
    return StreamBuilder<List<OrderItem>>(
      stream: order.value.orderItems,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        return Text(
          snap.hasData ? '${snap.data.length} Item(s)' : "Error",
          style: FontHelper.medium14TextStyle,
          textAlign: TextAlign.right,
        );
      },
    );
  }

  _buildTapToLocation() {
    return Align(
      alignment: Alignment.centerRight,
      child: StreamBuilder<GeoPoint>(
        stream: order.value.deliveryLocation,
        builder: (context, snap) {
          return GestureDetector(
              child: Image.asset('assets/icons/google-maps.png'),
              onTap: () {
                LatLng temp = LatLng(snap.data.latitude, snap.data.longitude);
                launchMaps(temp);
              });
        },
      ),
    );
  }

  _buildOrderItems() {
    return StreamBuilder<List<OrderItem>>(
      stream: order.value.orderItems,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        return _buildOrderItemList(context, snap.data);
      },
    );
  }

  Widget _buildOrderItemList(BuildContext context, List<OrderItem> snapshot) {
    return Wrap(
      children: snapshot.map((data) => _buildOrderItem(context, data)).toList(),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem orderItem) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxHeight: 50),
        padding: EdgeInsets.all(6),
        color: Color(0xFFF5F5F5),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(3, 0, 8, 0),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset('assets/icons/icon_menu_orange.png')),
            ),
            Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    StreamBuilder(
                      stream: orderItem.name,
                      builder: (context, item) {
                        if (!item.hasData) return Offstage();
                        return Text(
                          '${item.data}',
                          style: FontHelper.bold12Black,
                        );
                      },
                    ),
                    StreamBuilder(
                      stream: orderItem.description,
                      builder: (context, item) {
                        if (!item.hasData) return Offstage();
                        return Text(
                          '${item.data}',
                          maxLines: 2,
                          style: FontHelper.medium10greyTextStyle,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                )),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  StreamBuilder(
                    stream: orderItem.price,
                    builder: (context, item) {
                      if (!item.hasData) return Offstage();
                      return Text(
                        'Max: ' + StringHelper.doubleToPriceString(item.data),
                        style: FontHelper.regular10Black,
                      );
                    },
                  ),
                  StreamBuilder(
                    stream: orderItem.quantity,
                    builder: (context, item) {
                      if (!item.hasData) return Offstage();
                      return Text(
                        'X${item.data}',
                        style: FontHelper.bold12Black,
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 5, 11, 5),
            child: OutlineButton(
              onPressed: () {},
              child: Container(
                child: Text(
                  'LEAVE FEEDBACK',
                  style: FontHelper.semiBoldgrey14TextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 5, 11, 5),
            child: FlatButton(
              color: Color(0xFF959DAD),
              onPressed: () {
                showOverlay(order.value);
              },
              child: Container(
                child: Text(
                  'COUNTER-OFFER DELIVERY FEE',
                  style: FontHelper.semiBold12White,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  showOverlay(Order order) {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return CounterOfferOverlay(
            order: order,
            // route: widget.route,
          );
        });
  }

  Widget _buildMessages() {
    return Flexible(
      child: StreamBuilder<List<Message>>(
        stream: widget.channel.listOfMessages.map((data) {
          List<Message> temp = List<Message>();

          data.forEach((element) {
            temp.add(element);
          });
          temp.sort((a, b) => b.timestamp.value.compareTo(a.timestamp.value));
          return temp.toList();
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
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
              DateTimeHelper.convertDateTimeToTime(data.timestamp.value),
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
        return Row(
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
                            Icons.image,
                            size: 50,
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
                //TODO CHANGE DEFAULT IMAGE
                child: Icon(
                  Icons.check_circle,
                  size: 30,
                ),
              ),
              errorWidget: Icon(Icons.account_circle),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HeroPhotoViewWrapper(
                          tag: data.imageUrl.value,
                          imageProvider: NetworkImage(data.imageUrl.value),
                        ),
                  ));
            },
          ),
          Text(
            DateTimeHelper.convertDateTimeToTime(data.timestamp.value),
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
          DateTimeHelper.convertDateTimeToNewLineDate(data.timestamp.value),
          style: FontHelper.smallTimeTextStyle,
        ),
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                child: GestureDetector(
              onTap: getImageFromGallery,
              child: Icon(Icons.camera_alt),
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
                  controller: _textController,
                  style: TextStyle(height: 1, color: Colors.black),
                  decoration: const InputDecoration(
                      hintStyle: FontHelper.regular15Grey,
                      hintText: "Enter your message",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      border: OutlineInputBorder()),
                )),
            Expanded(
                child: Container(
                    child: GestureDetector(
                        onTap: () {
                          if (_textController.text != '') {
                            widget.channel.addMessage(
                                _textController.text,
                                ConfigHelper
                                    .instance.currentUserProperty.value.uid,
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
                        child: Icon(
                          Icons.send,
                          color:
                              sendButtonFlag ? Colors.black : Colors.grey[300],
                        ))))
          ],
        ),
      ),
    );
  }

  void getImageFromGallery() async {
    ImagePicker.pickImage(source: ImageSource.camera).then((image) async {
      if (image != null) {
        _image = await _cropImage(image);
        final StorageReference profileRef = FirebaseStorage.instance.ref().child(
            'user/${ConfigHelper.instance.currentUserProperty.value.uid}/${_image.hashCode}.jpg');

        final StorageUploadTask imageTask = profileRef.putFile(_image);

        imageTask.onComplete.then((result) {
          result.ref.getDownloadURL().then((url) {
            widget.channel.addMessage(
                null, ConfigHelper.instance.currentUserProperty.value.uid, url);
          });
        });
      }
    });
  }

  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      toolbarColor: ColorHelper.dabaoOrange,
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 300,
      maxHeight: 300,
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
