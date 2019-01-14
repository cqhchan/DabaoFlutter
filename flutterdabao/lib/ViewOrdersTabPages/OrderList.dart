import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/Conversation.dart';
import 'package:flutterdabao/CustomWidget/ExpansionTile.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
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
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Profile/ViewProfile.dart';
import 'package:flutterdabao/ViewOrdersTabPages/ConfirmationOverlay.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:random_string/random_string.dart' as random;

class OrderList extends StatefulWidget {
  final Observable<List<Order>> input;
  final LatLng location;
  final DabaoRoute.Route route;
  final context;

  OrderList(
      {Key key, this.context, @required this.input, this.location, this.route})
      : super(key: key);

  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> with HavingSubscriptionMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  // Current User Location
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<Order>>(
      stream: widget.input,
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) return Offstage();
        return ListView(
          key: new Key(random.randomString(20)),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30.0),
          children: snapshot.data
              .map((data) => _OrderItemCell(
                    order: data,
                    location: widget.location,
                    route: widget.route,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _OrderItemCell extends StatefulWidget {
  final DabaoRoute.Route route;
  final Order order;
  final LatLng location;

  _OrderItemCell({this.route, @required this.order, this.location});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OrderItemCellState();
  }
}

class _OrderItemCellState extends State<_OrderItemCell>
    with HavingSubscriptionMixin {
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  @override
  void initState() {
    super.initState();

    listOfOrderItems = widget.order.orderItem;
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _buildListItem(widget.order);
  }

  Card _buildListItem(Order order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(11.0),
      color: Colors.white,
      elevation: 6.0,
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 16, 10, 10),
        child: Wrap(
          children: <Widget>[
            ConfigurableExpansionTile(
              selectable: order,
              initiallyExpanded: order.isSelectedProperty.value,
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildHeader(order),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 50),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: _buildDeliveryPeriod(order),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: _buildQuantity(order),
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
                        maxWidth: MediaQuery.of(context).size.width - 50),
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
                            child:
                                Image.asset("assets/icons/red_marker_icon.png"),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: _buildLocationDescription(order),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildTapToLocation(order),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: StreamBuilder<bool>(
                      stream: widget.order.isSelectedProperty.producer,
                      builder: (BuildContext context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data) return Offstage();

                        return Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Tap Card for Order Summary",
                              textAlign: TextAlign.center,
                              style: FontHelper.medium(
                                  ColorHelper.dabaoOffBlack9B, 12),
                            ));
                      },
                    ),
                  )
                ],
              ),
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _buildOrderItems(order),
                    StreamBuilder<bool>(
                      stream: widget.order.isSelectedProperty.producer,
                      builder: (BuildContext context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data == null ||
                            !snapshot.data) return Offstage();

                        return Text(
                          "Tap to minimize",
                          style: FontHelper.medium(
                              ColorHelper.dabaoOffBlack9B, 12),
                        );
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                )
              ],
            ),
            StreamBuilder<bool>(
              stream: order.isSelectedProperty.producer,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Offstage();
                if (snapshot.data) {
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildUser(order),
                          ),
                          _buildChatButton(order),
                          SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      _buildPickUpButton(order)
                    ],
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Divider(
                        height: 13,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 5),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildUser(order),
                            ),
                            _buildChatButton(order),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Order order) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 50),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: StreamBuilder<String>(
              stream: order.foodTag,
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
              stream: order.deliveryFee,
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

  Widget _buildDeliveryPeriod(Order order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        StreamBuilder<String>(
          stream: Observable.combineLatest2<OrderMode, DateTime, String>(
              order.mode, order.startDeliveryTime, (mode, start) {
            DateTime endTime;
            DateTime startTime;
            DateTime currentTime = DateTime.now();
            if (mode == null) return "Error";

            switch (mode) {
              case OrderMode.asap:
                setState(() {
                  endTime = order.endDeliveryTime.value == null
                      ? currentTime.add(Duration(minutes: 90))
                      : order.endDeliveryTime.value;
                  startTime = currentTime.isAfter(endTime)
                      ? endTime.subtract(Duration(minutes: 60))
                      : currentTime;
                });

                break;
              case OrderMode.scheduled:
                setState(() {
                  endTime = order.endDeliveryTime.value;
                  startTime = start;
                });

                break;
            }
            return DateTimeHelper.convertDoubleTimeToDisplayString(
                startTime, endTime);
          }),
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();

            return Text(
              snap.data,
              style: FontHelper.semiBoldgrey14TextStyle,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        StreamBuilder<DateTime>(
          stream: order.endDeliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            return Expanded(
              child: Text(
                snap.hasData
                    ? '-' + DateTimeHelper.convertDateTimeToAMPM(snap.data)
                    : '',
                style: FontHelper.semiBoldgrey14TextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuantity(Order order) {
    return StreamBuilder<List<OrderItem>>(
      stream: listOfOrderItems.producer,
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

  Widget _buildOrderItems(Order order) {
    return StreamBuilder<List<OrderItem>>(
      stream: listOfOrderItems.producer,
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

  Widget _buildLocationDescription(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCollapsableLocationDescription(order),
            StreamBuilder<GeoPoint>(
              stream: order.deliveryLocation,
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

  Widget _buildCollapsableLocationDescription(Order order) {
    return StreamBuilder<bool>(
      stream: order.isSelectedProperty.producer,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        if (!snap.data) {
          return StreamBuilder<String>(
            stream: order.deliveryLocationDescription,
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
            stream: order.deliveryLocationDescription,
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
      },
    );
  }

  Widget _buildTapToLocation(Order order) {
    return Align(
      alignment: Alignment.centerRight,
      child: StreamBuilder<GeoPoint>(
        stream: order.deliveryLocation,
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

  Widget _buildUser(Order order) {
    return StreamBuilder<User>(
      stream: order.creator
          .where((uid) => uid != null)
          .map((uid) => User.fromUID(uid)),
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

  Widget _buildPickUpButton(Order order) {
    return RaisedButton(
      elevation: 6,
      color: ColorHelper.availableColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Align(
              child: Text(
                "Pick Up",
                style: FontHelper.semiBold14Black,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        showOverlay(order);
      },
    );
  }

  Widget _buildChatButton(Order order) {
    return GestureDetector(
      onTap: () {
        _toChat(order);
      },
      child: Container(
          height: 30,
          child: Icon(
            Icons.chat,
            size: 30,
          )),
    );
  }

  showOverlay(Order order) {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return ConfirmationOverlay(
            order: order,
            route: widget.route,
          );
        });
  }

  _toChat(Order order) {
    Channel channel = Channel.fromUID(
        order.uid + ConfigHelper.instance.currentUserProperty.value.uid);
    Firestore.instance.collection("channels").document(channel.uid).setData(
      {
        "O": order.uid,
        "P": [
          ConfigHelper.instance.currentUserProperty.value.uid,
          order.creator.value
        ],
        "D": ConfigHelper.instance.currentUserProperty.value.uid
      },
      merge: true,
    ).then((_) {
      GlobalKey<ConversationState> key =
          GlobalKey<ConversationState>(debugLabel: channel.uid);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Conversation(
                channel: channel,
                location: widget.location,
                key: key,
              ),
        ),
      );
    });
  }
}
