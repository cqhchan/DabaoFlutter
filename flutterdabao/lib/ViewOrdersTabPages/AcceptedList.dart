import 'dart:ui';
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
import 'package:flutterdabao/OrderWidget/StatusColor.dart';
import 'package:flutterdabao/Profile/ViewProfile.dart';
import 'package:flutterdabao/ViewOrders/ViewOrderPage.dart';
import 'package:flutterdabao/ViewOrdersTabPages/CompletedOverlay.dart';
import 'package:flutterdabao/ViewOrdersTabPages/ConfirmedSummary.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:random_string/random_string.dart' as random;

class AcceptedList extends StatefulWidget {
  final Observable<List<Order>> input;
  final LatLng location;
  final DabaoRoute.Route route;

  AcceptedList({Key key, @required this.input, this.location, this.route})
      : super(key: key);

  _AcceptedListState createState() => _AcceptedListState();
}

class _AcceptedListState extends State<AcceptedList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  StreamBuilder _buildBody() {
    return StreamBuilder<List<Order>>(
      stream: widget.input,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Offstage();
        return _buildList(context, snapshot.data);
      },
    );
  }

  ListView _buildList(BuildContext context, List<Order> snapshot) {
    return ListView(
      key: new Key(random.randomString(20)),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      children: snapshot
          .map((data) => _AcceptedOrderCell(
                location: widget.location,
                order: data,
                route: widget.route,
              ))
          .toList(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _AcceptedOrderCell extends StatefulWidget {
  final LatLng location;
  final DabaoRoute.Route route;
  final Order order;

  const _AcceptedOrderCell(
      {Key key,
      @required this.location,
      @required this.route,
      @required this.order})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _AcceptedOrderCellState();
  }
}

class _AcceptedOrderCellState extends State<_AcceptedOrderCell>
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
    return _buildListItem();
  }

  Widget _buildListItem() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(11.0),
      color: Colors.white,
      elevation: 6.0,
      child: Stack(
        children: <Widget>[
          StatusColor(
            color: ColorHelper.dabaoOrange,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 16, 10, 10),
            child: Wrap(
              children: <Widget>[
                ConfigurableExpansionTile(
                  selectable: widget.order,
                  initiallyExpanded: widget.order.isSelectedProperty.value,
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildHeader(widget.order),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 50),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildDeliveryPeriod(widget.order),
                            ),
                            _buildQuantity(widget.order),
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
                                child: Image.asset(
                                    "assets/icons/red_marker_icon.png"),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: _buildLocationDescription(widget.order),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildTapToLocation(widget.order),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        _buildOrderItems(widget.order),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    )
                  ],
                ),
                StreamBuilder<bool>(
                  stream: widget.order.isSelectedProperty.producer,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Offstage();
                    if (snapshot.data) {
                      return Column(
                        children: <Widget>[
                          Flex(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: _buildUser(widget.order),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: _buildChatButton(widget.order)),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          _buildPickUpButton(widget.order)
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
                            child: Flex(
                              direction: Axis.horizontal,
                              children: <Widget>[
                                Expanded(
                                  flex: 4,
                                  child: _buildUser(widget.order),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: _buildChatButton(widget.order)),
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
          Positioned.fill(
            child: StreamBuilder<String>(
              stream: widget.order.status,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return Offstage(
                  offstage: snap.data == 'Completed' ? false : true,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Color(0xFF707070).withOpacity(0.5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Completed',
                            style: FontHelper.bold50White,
                          ),
                          _buildTapToViewButton(widget.order)
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
    return StreamBuilder<DateTime>(
      stream: order.deliveryTime,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        return Text(
          DateTimeHelper.convertTimeToDisplayString(snap.data),
          style: FontHelper.semiBoldgrey14TextStyle,
          overflow: TextOverflow.ellipsis,
        );
      },
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
    return GestureDetector(
        onTap: () {
          orderItem.updateBought(widget.order, !orderItem.isBought.value);
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 45),
          child: Container(
            padding: EdgeInsets.only(top: 5, left: 5, right: 5),
            color: ColorHelper.dabaoOffWhiteF5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 30.0,
                  margin: EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: StreamBuilder<bool>(
                      stream: orderItem.isBought,
                      builder: (BuildContext context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data == null ||
                            !snapshot.data)
                          return Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorHelper.dabaoOrange,
                                width: 1.5,
                              ),
                            ),
                          );
                        else
                          return Icon(
                            Icons.check_circle,
                            color: ColorHelper.dabaoOrange,
                            size: 18,
                          );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        orderItem.name.value,
                        style: FontHelper.semiBold12Black,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        orderItem.description.value,
                        style: FontHelper.semiBold(
                            ColorHelper.dabaoOffBlack4A, 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                      "Max: ${StringHelper.doubleToPriceString(orderItem.price.value)}",
                      style: FontHelper.regular12Black),
                )
              ],
            ),
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
      color: ColorHelper.dabaoOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Align(
              child: Text(
                "Go to Order",
                style: FontHelper.semiBold14Black,
              ),
            ),
          ),
          Expanded(
            child: Align(
                child: Icon(Icons.keyboard_arrow_right, color: Colors.black)),
          ),
        ],
      ),
      onPressed: () {
        Navigator.of(context).push(FadeRoute(
            widget: DabaoerViewOrderListPage(
          order: Order.fromUID(widget.order.uid),
        )));
      },
    );
  }

  Widget _buildTapToViewButton(Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70.0),
      child: RaisedButton(
        elevation: 6,
        color: ColorHelper.dabaoOffPaleBlue,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(
                child: Text(
                  "Tap To View",
                  style: FontHelper.semiBold14White,
                ),
              ),
            ),
          ],
        ),
        onPressed: () async {
          Navigator.of(context).push(FadeRoute(
              widget: DabaoerViewOrderListPage(
            order: Order.fromUID(widget.order.uid),
          )));
        },
      ),
    );
  }

  Widget _buildChatButton(Order order) {
    return Container(
      height: 30,
      child: RaisedButton(
        elevation: 6,
        color: ColorHelper.dabaoOrange,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(
                child: Text(
                  "Chat",
                  style: FontHelper.semiBold14Black,
                ),
              ),
            ),
          ],
        ),
        onPressed: () async {
          _toChat(order);
        },
      ),
    );
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
