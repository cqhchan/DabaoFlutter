import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/CounterOfferOverlay.dart';
import 'package:flutterdabao/CustomWidget/ExpansionTile.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMaps.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart' as Rxdart;

class ConversationCard extends StatefulWidget {
  final bool expandFlag;
  final MutableProperty<Order> order;
  final LatLng location;
  final Channel channel;

  const ConversationCard(
      {Key key, this.expandFlag, this.order, this.location, this.channel})
      : super(key: key);
  @override
  _ConversationCardState createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard> {
  Color colorStatus = ColorHelper.dabaoOrange;

  @override
  Widget build(BuildContext context) {
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
            offstage: widget.expandFlag,
            child: _buildCard(),
          ),
          StreamBuilder<bool>(
            stream:
                Rxdart.Observable.combineLatest3<User, String, String, bool>(
                    ConfigHelper.instance.currentUserProperty.producer,
                    widget.order.producer.switchMap((currentOrder) =>
                        currentOrder == null ? null : currentOrder.creator),
                    widget.order.producer.switchMap((currentOrder) =>
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
              return _buildButtons(snapshot.data);
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
          stream: widget.order.producer.switchMap((order) {
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
                  color: colorStatus,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 16, 10, 10),
                child: Wrap(
                  children: <Widget>[
                    StreamBuilder(
                      stream: widget.order.producer.switchMap((order) =>
                          order != null
                              ? order.deliveryLocationDescription
                              : Rxdart.Observable.just(null)),
                      builder: (context, snap) {
                        if (!snap.hasData || snap.data == null)
                          return Offstage();
                        return ConfigurableExpansionTile(
                          selectable: widget.order.value,
                          initiallyExpanded: false,
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
              stream: widget.order.value.foodTag,
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
              stream: widget.order.value.deliveryFee,
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
        stream: widget.order.producer
            .switchMap((order) => order == null ? null : order.mode),
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null) return Offstage();
          DateTime startTime;
          DateTime endTime;

          switch (snap.data) {
            case OrderMode.asap:
              startTime = DateTime.now();
              endTime = widget.order.value.endDeliveryTime.value == null
                  ? startTime.add(Duration(minutes: 90))
                  : widget.order.value.endDeliveryTime.value;
              break;
            case OrderMode.scheduled:
              startTime = widget.order.value.startDeliveryTime.value;
              endTime = widget.order.value.endDeliveryTime.value;
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

  Widget _buildQuantity() {
    return StreamBuilder<List<OrderItem>>(
      stream: widget.order.value.orderItem.producer,
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

  _buildOrderItems() {
    return StreamBuilder<List<OrderItem>>(
      stream: widget.order.value.orderItem.producer,
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

  Widget _buildButtons(data) {
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
                showOverlay(widget.order.value);
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
            //TODO COUNTER-OFFER DELIVERY FEE
            order: order,
            // route: widget.route,
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
              stream: widget.order.value.deliveryLocation,
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

  _buildTapToLocation() {
    return Align(
      alignment: Alignment.centerRight,
      child: StreamBuilder<GeoPoint>(
        stream: widget.order.value.deliveryLocation,
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

  Widget _buildCollapsableLocationDescription() {
    if (!widget.channel.isSelectedProperty.value) {
      return StreamBuilder<String>(
        stream: widget.order.value.deliveryLocationDescription,
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
        stream: widget.order.value.deliveryLocationDescription,
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
}
