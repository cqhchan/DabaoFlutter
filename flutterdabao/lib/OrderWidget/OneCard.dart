import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/OrderWidget/StatusColor.dart';
import 'package:flutterdabao/ViewOrdersTabPages/ConfirmationOverlay.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart' as Rxdart;

class OneCard extends StatefulWidget {
  final Channel channel;
  final LatLng location;
  final bool expandFlag;

  const OneCard({Key key, this.location, this.channel, this.expandFlag}) : super(key: key);

  _OneCardState createState() => _OneCardState();
}

class _OneCardState extends State<OneCard> with HavingSubscriptionMixin {
  MutableProperty<Order> order = MutableProperty(null);
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  //expansion of whole card

  @override
  void initState() {
    super.initState();

    subscription.add(listOfOrderItems.bindTo(order.producer
        .where((uid) => uid != null)
        .switchMap((o) => o == null
            ? Rxdart.Observable.just(List())
            : o.orderItem.producer)));

    subscription.add(order.bindTo(widget.channel.orderUid
        .where((uid) => uid != null && (order.value == null ||  uid != order.value.uid))
        .map((uid) => Order.fromUID(uid))));
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height *0.65 ),
          child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Column(
      children: <Widget>[
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
          margin: EdgeInsets.fromLTRB(11, 0, 11, 11),
          color: Colors.white,
          elevation: 6.0,
          child: Stack(
            children: <Widget>[
              StreamBuilder<String>(
                  stream: order.producer.switchMap((order) => order != null
                      ? order.status
                      : Rxdart.Observable.just(null)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Offstage();
                    return StatusColor(
                      color: snapshot.data == orderStatus_Requested 
                          ? ColorHelper.availableColor 
                          : ConfigHelper.instance.currentUserProperty.value.uid == order.value.delivererID.value ?ColorHelper.dabaoOrange :  ColorHelper.notAvailableColor,
                    );
                  }),
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
                                      child: _buildLocationDescription(
                                          order.value),
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
                              _buildStatusReport(order.value),
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

          if (startTime.isBefore(endTime) && endTime.isBefore(DateTime.now()))
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

  Widget _buildQuantity() {
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

  Widget _buildTapToLocation() {
    return Align(
      alignment: Alignment.centerRight,
      child: StreamBuilder<GeoPoint>(
        stream: order.value.deliveryLocation,
        builder: (context, snap) {
          return GestureDetector(
              child: Image.asset('assets/icons/google-maps.png'),
              onTap: () {
                var temp = LatLng(snap.data.latitude, snap.data.longitude);
                launchMaps(temp);
              });
        },
      ),
    );
  }

  Widget _buildStatusReport(Order order) {
    return StreamBuilder<String>(
        stream: order.status,
        builder: (context, statusSnap) {
          if (!statusSnap.hasData) return Offstage();
          return Row(
            children: <Widget>[
              Text(
                'Status: ',
                style: FontHelper.semiBold14Black,
                overflow: TextOverflow.ellipsis,
              ),
              StreamBuilder<bool>(
                stream: Rxdart.Observable.combineLatest2<String, User, bool>(
                    order.delivererID,
                    ConfigHelper.instance.currentUserProperty.producer,
                    (userID, currentUser) {
                  if (userID == null || currentUser == null) return null;

                  return userID == currentUser.uid;
                }),
                builder: (BuildContext context, imDeliveryingSnap) {
                  return Text(
                    statusSnap.data == orderStatus_Requested
                        ? 'Available for Pick Up'
                        : imDeliveryingSnap.data == true &&
                                statusSnap.data == orderStatus_Accepted || statusSnap.data == orderStatus_Completed
                            ? 'Picked Up'
                            : "Order Picked up by someone else",
                    style: statusSnap.data == orderStatus_Requested
                        ? FontHelper.semiBold14Available
                        : imDeliveryingSnap.data == true &&
                                statusSnap.data == orderStatus_Accepted
                            ? FontHelper.semiBold(ColorHelper.dabaoOrange, 14.0)
                            : FontHelper.semiBold14NotAvailable,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              )
            ],
          );
        });
  }

  Widget _buildOrderItems() {
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

  Widget _buildButtons() {
    return StreamBuilder(
        stream: order.producer.value.status,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Offstage();
          return Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 5, 11, 5),
                  child: RaisedButton(
                    textColor: Colors.black,
                    disabledColor: ColorHelper.disableColor,
                    disabledTextColor: ColorHelper.disableTextColor,
                    color: ColorHelper.availableColor,
                    onPressed: snapshot.data == orderStatus_Requested
                        ? () {
                            showConfirm(order.value);
                          }
                        : null,
                    child: Container(
                      child: Text(
                        'PICK UP ORDER',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 5, 11, 5),
                  child: RaisedButton(
                    textColor: Colors.white,
                    disabledColor: ColorHelper.disableColor,
                    disabledTextColor: ColorHelper.disableTextColor,
                    color: ColorHelper.counterOfferColor,
                    onPressed: snapshot.data == orderStatus_Requested
                        ? () {
                            showCounter(order.value);
                          }
                        : null,
                    child: Container(
                      child: Text(
                        'COUNTER-OFFER DELIVERY FEE',
                        // style: FontHelper.semiBold12White,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  showConfirm(Order order) {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return ConfirmationOverlay(
            order: order,
            // route: widget.route,
          );
        });
  }

  showCounter(Order order) {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return CounterOfferOverlay(
            order: order,
            // route: widget.route,
          );
        });
  }
}
