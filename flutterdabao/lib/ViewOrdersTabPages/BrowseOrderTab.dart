import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/ExpansionTile.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/ViewOrdersTabPages/ConfirmationOverlay.dart';
import 'package:flutterdabao/ViewOrdersTabPages/ViewMap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class BrowseOrderTabView extends StatefulWidget {
  _BrowseOrderTabViewState createState() => _BrowseOrderTabViewState();
}

class _BrowseOrderTabViewState extends State<BrowseOrderTabView>
    with HavingSubscriptionMixin {
  final MutableProperty<List<Order>> userRequestedOrders =
      ConfigHelper.instance.currentUserRequestedOrdersProperty;

  bool expandedFlag = false;

  // Current User Location
  MutableProperty<LatLng> currentLocation =
      ConfigHelper.instance.currentLocationProperty;

  @override
  void dispose() {
    // TODO: implement dispose
    Selectable.deselectAll(userRequestedOrders.value);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  StreamBuilder _buildBody(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: userRequestedOrders.producer,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Offstage();
        return _buildList(context, snapshot.data);
      },
    );
  }

  ListView _buildList(BuildContext context, List<Order> snapshot) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Card _buildListItem(BuildContext context, Order order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(10.0),
      color: Colors.white,
      elevation: 6.0,
      child: Container(
        margin: EdgeInsets.all(13),
        child: Wrap(
          children: <Widget>[
            StreamBuilder(
              stream: order.deliveryLocationDescription,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return ConfigurableExpansionTile(
                  initiallyExpanded: false,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      expandedFlag = expanded;
                    });
                    order.toggle();
                  },
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildHeader(order),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 50),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: _buildDeliveryPeriod(order),
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildQuantity(order),
                            ),
                          ],
                        ),
                      ),
                      buildHeightBox(),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 50),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: _buildLocationDescription(order),
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildTapToLocation(order),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        buildHeightBox(),
                        _buildOrderItems(order),
                      ],
                    )
                  ],
                );
              },
            ),
            StreamBuilder<bool>(
              stream: order.isSelectedProperty.producer,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Offstage();
                if (snapshot.data) {
                  return Column(
                    children: <Widget>[
                      buildHeightBox(),
                      _buildUser(order),
                      _buildPickUpButton(order),
                    ],
                  );
                  // what to do if expanded
                } else {
                  return Column(
                    children: <Widget>[
                      Divider(),
                      buildHeightBox(),
                      _buildUser(order),
                    ],
                  );
                  // what to do if not expanded
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
            flex: 4,
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
                    style: FontHelper.semiBold16(ColorHelper.dabaoOffBlack4A),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: StreamBuilder<double>(
              stream: order.deliveryFee,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return Text(
                  snap.hasData
                      ? StringHelper.doubleToPriceString(snap.data)
                      : "Error",
                  style: FontHelper.semiBold14Black2,
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
      children: <Widget>[
        StreamBuilder<DateTime>(
          stream: order.startDeliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            if (snap.data.day == DateTime.now().day &&
                snap.data.month == DateTime.now().month &&
                snap.data.year == DateTime.now().year) {
              return Text(
                'Today, ' + DateTimeHelper.convertDateTimeToAMPM(snap.data) + ' - ' + DateTimeHelper.convertDateTimeToAMPM(snap.data.add(Duration(hours: 2))) ,
                style: FontHelper.semiBoldgrey14TextStyle,
                overflow: TextOverflow.ellipsis,
              );
            } else {
              return Container(
                child: Text(
                  snap.hasData
                      ? DateTimeHelper.convertDateTimeToDate(snap.data) +
                          ', ' +
                          DateTimeHelper.convertDateTimeToAMPM(snap.data)
                      : "Error",
                  style: FontHelper.semiBoldgrey14TextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
          },
        ),
        StreamBuilder<DateTime>(
          stream: order.endDeliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            return Material(
              child: Text(
                snap.hasData
                    ? ' - ' + DateTimeHelper.convertDateTimeToAMPM(snap.data)
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
      stream: order.orderItems,
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
      stream: order.orderItems,
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
        constraints: BoxConstraints(maxHeight: 40),
        padding: EdgeInsets.all(6),
        color: Colors.grey[200],
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Image.asset('assets/icons/icon_menu_orange.png')),
            Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                          style: FontHelper.medium10TextStyle,
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
                        StringHelper.doubleToPriceString(item.data),
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
        Icon(Icons.location_on, color: Colors.red[800]),
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
                if (currentLocation.value.latitude != null &&
                    currentLocation.value.longitude != null &&
                    snap.data.latitude != null &&
                    snap.data.longitude != null) {
                  return Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 180),
                    child: Text(
                      snap.hasData
                          ? LocationHelper.calculateDistancFromSelf(
                                      currentLocation.value.latitude,
                                      currentLocation.value.longitude,
                                      snap.data.latitude,
                                      snap.data.longitude)
                                  .toStringAsFixed(1) +
                              'km away'
                          : "?.??km",
                      style: FontHelper.medium12TextStyle,
                    ),
                  );
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollapsableLocationDescription(Order order) {
    if (!expandedFlag) {
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ViewMap(
                              latitude: order.deliveryLocation.value.latitude,
                              longitude: order.deliveryLocation.value.longitude,
                            )));
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
        return Row(
          children: <Widget>[
            StreamBuilder<String>(
              stream: user.data.thumbnailImage,
              builder: (context, user) {
                if (!user.hasData) return Offstage();
                return CircleAvatar(
                  child: user.hasData
                      ? Image.network(user.data)
                      : Icon(Icons.person),
                  radius: 11.5,
                );
              },
            ),
            buildWidthBox(),
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

  Widget _buildPickUpButton(Order order) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FlatButton(
        color: ColorHelper.dabaoOrange,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(
                child: Text(
                  "Pick Up",
                  style: FontHelper.semiBold14Black2,
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          showOverlay(order);
        },
      ),
    );
  }

  showOverlay(Order order) {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return ConfirmationOverlay(
            order: order,
          );
        });
  }

  Widget buildHeightBox() {
    return SizedBox(
      height: 8,
    );
  }

  Widget buildWidthBox() {
    return SizedBox(
      width: 10,
    );
  }
}
