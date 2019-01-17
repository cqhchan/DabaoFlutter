import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/CounterOfferOverlay.dart';
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
import 'package:flutterdabao/ViewOrders/ViewOrderPage.dart';
import 'package:flutterdabao/ViewOrdersTabPages/ConfirmationOverlay.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart' as Rxdart;

enum CardMode {
  dabaoeeCancelled,
  dabaoeeRequested,
  dabaoeeAcceptedByOther,
  dabaoeeAccepted,
  dabaoeeCompleted,
  dabaoerCancelled,
  dabaoerRequested,
  dabaoerAcceptedByOthers,
  dabaoerAccepted,
  dabaoerCompleted
}

class OneCard extends StatefulWidget {
  final Channel channel;
  final LatLng location;
  final bool expandFlag;

  const OneCard({Key key, this.location, this.channel, this.expandFlag})
      : super(key: key);

  _OneCardState createState() => _OneCardState();
}

class _OneCardState extends State<OneCard> with HavingSubscriptionMixin {
  MutableProperty<Order> order = MutableProperty(null);
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());
  MutableProperty<CardMode> mode = MutableProperty(null);

  //expansion of whole card

  @override
  void initState() {
    super.initState();

    subscription.add(mode.bindTo(Rxdart.Observable.combineLatest4<User, String,
            String, String, CardMode>(
        ConfigHelper.instance.currentUserProperty.producer,
        order.producer
            .switchMap((order) => order == null ? null : order.status),
        order.producer
            .switchMap((order) => order == null ? null : order.delivererID),
        widget.channel.deliverer,
        (currentUser, orderStatus, delivererID, channelCreatorID) {
      if (orderStatus == null ||
          currentUser == null ||
          channelCreatorID == null) return null;
      //Dabaoer
      if (currentUser.uid == channelCreatorID) {
        if (orderStatus == orderStatus_Requested) {
          return CardMode.dabaoerRequested;
        }
        // Order has moved past requested
        if (delivererID != null) {
          // im the deliverer
          if (delivererID == currentUser.uid) {
            if (orderStatus == orderStatus_Cancelled)
              return CardMode.dabaoerCancelled;
            else if (orderStatus == orderStatus_Accepted)
              return CardMode.dabaoerAccepted;
            else
              return CardMode.dabaoerCompleted;
          } else {
            return CardMode.dabaoerAcceptedByOthers;
          }
        }
        return CardMode.dabaoerCancelled;
        //Dabaoee
      } else {
        if (orderStatus == orderStatus_Requested) {
          return CardMode.dabaoeeRequested;
        }
        // Order has moved past requested
        if (delivererID != null) {
          // im talking to the deliverer
          if (delivererID == channelCreatorID) {
            if (orderStatus == orderStatus_Cancelled)
              return CardMode.dabaoeeCancelled;
            else if (orderStatus == orderStatus_Accepted)
              return CardMode.dabaoeeAccepted;
            else
              return CardMode.dabaoeeCompleted;
          } else {
            return CardMode.dabaoeeAcceptedByOther;
          }
        }
        return CardMode.dabaoeeCancelled;
      }
    })));

    subscription.add(listOfOrderItems.bindTo(order.producer
        .where((uid) => uid != null)
        .switchMap((o) => o == null
            ? Rxdart.Observable.just(List())
            : o.orderItem.producer)));

    subscription.add(order.bindTo(widget.channel.orderUid
        .where((uid) =>
            uid != null && (order.value == null || uid != order.value.uid))
        .map((uid) => Order.fromUID(uid))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.start,
              children: <Widget>[
                Offstage(
                  offstage: widget.expandFlag,
                  child: _buildCard(),
                ),
                StreamBuilder<CardMode>(
                  stream: mode.producer,
                  builder: (BuildContext context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Offstage();

                    return _buildButtons(snapshot.data);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return StreamBuilder(
      stream: mode.producer,
      builder: (context, modeSnap) {
        if (modeSnap.data == null) return Offstage();
        return Column(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              margin: EdgeInsets.fromLTRB(11, 0, 11, 11),
              color: Colors.white,
              elevation: 6.0,
              child: Stack(
                children: <Widget>[
                  topBar(modeSnap.data),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 16, 10, 5),
                    child: Wrap(
                      children: <Widget>[
                        StreamBuilder(
                          stream: order.producer.switchMap((order) =>
                              order != null
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
                                            MediaQuery.of(context).size.width -
                                                50),
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
                                            padding: const EdgeInsets.only(
                                                right: 6.0),
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
                                            MediaQuery.of(context).size.width -
                                                50),
                                    child: Flex(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: _buildTapToLocation(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _buildStatusReport(modeSnap.data),
                                  Align(
                                    alignment: Alignment.center,
                                    child: StreamBuilder<bool>(
                                      stream: order
                                          .value.isSelectedProperty.producer,
                                      builder:
                                          (BuildContext context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.data == null ||
                                            snapshot.data) return Offstage();

                                        return Align(
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  "Tap Card for Order Summary",
                                                  textAlign: TextAlign.center,
                                                  style: FontHelper.medium(
                                                      ColorHelper
                                                          .dabaoOffBlack9B,
                                                      12),
                                                ),
                                                Icon(Icons.keyboard_arrow_down),
                                              ],
                                            ));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    _buildOrderItems(),
                                    _buildMessage(order.value),
                                    StreamBuilder<bool>(
                                      stream: order
                                          .value.isSelectedProperty.producer,
                                      builder:
                                          (BuildContext context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.data == null ||
                                            !snapshot.data) return Offstage();

                                        return Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "Tap to minimize",
                                              style: FontHelper.medium(
                                                  ColorHelper.dabaoOffBlack9B,
                                                  12),
                                            ),
                                            Icon(Icons.keyboard_arrow_up),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: 0,
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
      },
    );
  }

  Widget topBar(CardMode mode) {
    Color color;
    switch (mode) {
      case CardMode.dabaoerAccepted:
        color = ColorHelper.dabaoOrange;
        break;

      case CardMode.dabaoerCompleted:
        color = ColorHelper.dabaoOffPaleBlue;
        break;

      case CardMode.dabaoerRequested:
        color = ColorHelper.availableColor;
        break;

      default:
        color = ColorHelper.notAvailableColor;
    }

    return StatusColor(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0)),
      color: color,
    );
  }

  Widget _buildMessage(Order order) {
    return StreamBuilder<String>(
      stream: order.message,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        return Container(
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.fromLTRB(6.0, 15.0, 6.0, 15.0),
            color: ColorHelper.dabaoOffWhiteF5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("Message to Dabaoer", style: FontHelper.bold12Black),
                SizedBox(
                  height: 3,
                ),
                Text(snap.data, style: FontHelper.medium(Colors.black, 10))
              ],
            ));
      },
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
    return StreamBuilder<DateTime>(
        stream: order.producer
            .switchMap((order) => order == null ? null : order.deliveryTime),
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null)
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

                  if (startTime.isBefore(endTime) &&
                      endTime.isBefore(DateTime.now()))
                    return Text(
                      "Expired",
                      style: FontHelper.semiBoldgrey14TextStyle,
                      overflow: TextOverflow.ellipsis,
                    );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        DateTimeHelper.convertDoubleTimeToDisplayString(
                            startTime, endTime),
                        style: FontHelper.semiBoldgrey14TextStyle,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  );
                });
          else
            return Text(
              DateTimeHelper.convertTimeToDisplayString(snap.data),
              style: FontHelper.semiBoldgrey14TextStyle,
              overflow: TextOverflow.ellipsis,
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
                          : "",
                      style: FontHelper.medium12TextStyle,
                    ),
                  );
                } else {
                  return Text(
                    "",
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

  Widget _buildStatusReport(CardMode mode) {
    Color color;
    String status = "";
    switch (mode) {
      case CardMode.dabaoerAccepted:
        status = "Picked Up";
        color = ColorHelper.dabaoOrange;
        break;

      case CardMode.dabaoerCompleted:
        status = "Delivery Completed";
        color = ColorHelper.dabaoOffPaleBlue;
        break;

      case CardMode.dabaoerRequested:
        color = ColorHelper.availableColor;
        status = "Avaliable for Pick Up";
        break;

      case CardMode.dabaoerAcceptedByOthers:
        color = ColorHelper.notAvailableColor;
        status = "Order has been picked up by someone else";
        break;

      case CardMode.dabaoerCancelled:
        color = ColorHelper.notAvailableColor;
        status = "Order has been cancelled";
        break;

      default:
        color = ColorHelper.notAvailableColor;
    }

    return Row(children: <Widget>[
      Text(
        'Status: ',
        style: FontHelper.semiBold14Black,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        status,
        style: FontHelper.semiBold(color, 14.0),
        overflow: TextOverflow.ellipsis,
      )
    ]);
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

  Widget _buildButtons(CardMode mode) {
    switch (mode) {
      case CardMode.dabaoerRequested:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 5, 11, 5),
                child: RaisedButton(
                  textColor: Colors.black,
                  disabledColor: ColorHelper.disableColor,
                  disabledTextColor: ColorHelper.disableTextColor,
                  color: ColorHelper.availableColor,
                  onPressed: () {
                    showConfirm(order.value);
                  },
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
                  child: StreamBuilder<CounterOffer>(
                      stream: widget.channel.counterOffer,
                      builder: (context, snap) {
                        return RaisedButton(
                          textColor: Colors.white,
                          disabledColor: ColorHelper.disableColor,
                          disabledTextColor: ColorHelper.disableTextColor,
                          color: ColorHelper.counterOfferColor,
                          onPressed: snap.data == null ||
                                  snap.data.status !=
                                      CounterOffer.counterOffStatus_Open
                              ? () {
                                  showCounter(order.value);
                                }
                              : () {
                                  widget.channel.reject();
                                  widget.channel.addMessage(
                                      ConfigHelper.instance.currentUserProperty
                                              .value.name.value +
                                          " has cancelled the offer.",
                                      ConfigHelper.instance.currentUserProperty
                                          .value.uid,
                                      null);
                                },
                          child: Container(
                            child: Text(
                              snap.data == null ||
                                      snap.data.status !=
                                          CounterOffer.counterOffStatus_Open
                                  ? 'COUNTER-OFFER'
                                  : "CANCEL OFFER",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        );
                      })),
            ),
          ],
        );
      case CardMode.dabaoerAccepted:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 5, 11, 5),
                child: RaisedButton(
                  textColor: Colors.black,
                  color: ColorHelper.dabaoOrange,
                  onPressed: () {
                    Navigator.of(context).push(FadeRoute(
                        widget: DabaoerViewOrderListPage(
                      order: Order.fromUID(order.value.uid),
                    )));
                  },
                  child: Container(
                    child: Text(
                      'Go to Order',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case CardMode.dabaoerCompleted:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 5, 11, 5),
                child: RaisedButton(
                  textColor: Colors.black,
                  color: ColorHelper.dabaoOffPaleBlue,
                  onPressed: () {
                    Navigator.of(context).push(FadeRoute(
                        widget: DabaoerViewOrderListPage(
                      order: Order.fromUID(order.value.uid),
                    )));
                  },
                  child: Container(
                    child: Text(
                      'Tap To View',
                      textAlign: TextAlign.center,
                      style: FontHelper.semiBold(Colors.white, 14.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      default:
        return Offstage();
    }
  }

  showConfirm(Order order) {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return ConfirmationOverlay(
            order: order,
          );
        });
  }

  showCounter(Order order) {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return CounterOfferOverlay(
            order: order,
            channel: widget.channel,
          );
        });
  }
}
