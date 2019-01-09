import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/ChatNavigationButton.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMaps.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';

class DabaoeeViewOrderListPage extends StatefulWidget {
  final Order order;

  DabaoeeViewOrderListPage({Key key, this.order}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DabaoeeViewOrderListPageState();
  }
}

class _DabaoeeViewOrderListPageState extends State<DabaoeeViewOrderListPage> with HavingSubscriptionMixin {

  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());


  @override
  void initState() {
    super.initState();

    subscription.add(listOfOrderItems.bindTo(widget.order.orderItem));
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: ColorHelper.dabaoOffWhiteF5,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Your Order', style: FontHelper.header3TextStyle),
        actions: <Widget>[
          ChatNavigationButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(15.0, 20.0, 20.0, 20.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _DeliveryTime(order: widget.order),
                  orderStatus(widget.order),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20.0),
              child: _DeliveryLocation(
                order: widget.order,
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20.0),
              child: StreamBuilder<User>(
                stream: widget.order.delivererID
                    .map((id) => id == null ? null : User.fromUID(id)),
                builder: (BuildContext context, snapshot) {
                  return buildUser(snapshot.data);
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20.0),
              child: buildOrderID(widget.order),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Line(),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 5.0),
              child: _OrderItems(
                order: widget.order,
                listOfOrderItems: listOfOrderItems,
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Line(),
            ),
            buildTotal(widget.order),
          ],
        ),
      ),
    );
  }

  Widget buildTotal(Order order) {
    return StreamBuilder<double>(
      stream: Observable.combineLatest2<List<OrderItem>, double, double>(
          listOfOrderItems.producer, order.deliveryFee, (orderItems, deliveryFee) {
        double maxTotalPrice = orderItems
            .map(
                (orderItem) => orderItem.price.value * orderItem.quantity.value)
            .reduce((lhs, rhs) => lhs + rhs);

        double totalPrice = maxTotalPrice +
            (order.deliveryFeeDiscount.value == null
                ? deliveryFee
                : deliveryFee - order.deliveryFeeDiscount.value < 0
                    ? 0
                    : deliveryFee - order.deliveryFeeDiscount.value);
        return totalPrice;
      }),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return Offstage();
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Total", style: FontHelper.bold14Black),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("max.", style: FontHelper.regular12Black),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(StringHelper.doubleToPriceString(snapshot.data),
                      style: FontHelper.bold14Black),
                ],
              )
            ]);
      },
    );
  }

  Widget buildOrderID(Order order) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Order Code:",
            style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
            textAlign: TextAlign.center,
          ),
          Text(
            order.uid,
            style: FontHelper.regular14Black,
            textAlign: TextAlign.center,
          ),
        ]);
  }

  Widget buildUser(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Picked Up by:",
          style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
          textAlign: TextAlign.center,
        ),
        user == null
            ? Row(
                children: <Widget>[
                  Text("Searching for Dabaoer",
                      style:
                          FontHelper.semiBold(ColorHelper.dabaoOffGreyD3, 12)),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  StreamBuilder<String>(
                    stream: user.thumbnailImage,
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data == null) return Offstage();

                      return FittedBox(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: SizedBox(
                            height: 35,
                            width: 35,
                            child: CachedNetworkImage(
                              imageUrl: snap.data,
                              placeholder: GlowingProgressIndicator(
                                child: Icon(
                                  Icons.account_circle,
                                  size: 35,
                                ),
                              ),
                              errorWidget: Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  StreamBuilder<String>(
                    stream: user.name,
                    builder: (context, snap) {
                      if (snap.data == null) return Offstage();
                      return Container(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          snap.data,
                          style: FontHelper.regular14Black,
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Icon(
                      Icons.phone,
                      size: 25,
                    ),
                  )
                ],
              ),
      ],
    );
  }

  Widget orderStatus(Order order) {
    return Align(
      alignment: Alignment.topLeft,
      child: StreamBuilder<String>(
        stream: order.status,
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Offstage();
          }

          switch (snapshot.data) {
            case orderStatus_Accepted:
              return Container(
                height: 19,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: ColorHelper.dabaoOrange,
                ),
                child: Center(
                  child: Text(
                    "Enroute",
                    style: FontHelper.semiBold12Black,
                  ),
                ),
              );
            case orderStatus_Requested:
              return Container(
                height: 19,
                width: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Color.fromRGBO(0x95, 0x9D, 0xAD, 1.0)),
                child: Center(
                  child: Text("Pending",
                      style: FontHelper.semiBold(Colors.white, 12.0)),
                ),
              );
            case orderStatus_Completed:
              return Container(
                padding: EdgeInsets.only(left: 2.0),
                height: 19,
                width: 60,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Delivered",
                      style: FontHelper.semiBold(
                          ColorHelper.dabaoOffGreyD3, 12.0)),
                ),
              );
            default:
              return Offstage();
          }
        },
      ),
    );
  }
}

class _DeliveryTime extends StatelessWidget {
  final Order order;

  const _DeliveryTime({Key key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: order.status.switchMap((status) {
        switch (status) {
          case orderStatus_Accepted:
            return order.deliveryTime.map((date) => date == null
                ? "Error"
                : DateTimeHelper.convertTimeToDisplayString(date));

          case orderStatus_Completed:
            return order.completedTime.map((date) => date == null
                ? "Error"
                : DateTimeHelper.convertTimeToDisplayString(date));

          case orderStatus_Requested:
            return order.mode.switchMap((mode) {
              switch (mode) {
                case OrderMode.asap:
                  return BehaviorSubject(seedValue: "ASAP");
                case OrderMode.scheduled:
                  return Observable.combineLatest2(
                      order.startDeliveryTime, order.endDeliveryTime,
                      (start, end) {
                    if (start == null || end == null) return "Error";

                    return DateTimeHelper.convertDoubleTimeToDisplayString(
                        start, end);
                  });
              }
            });

          default:
            return BehaviorSubject(seedValue: null);
        }
      }),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Offstage();
        }
        return Text(
          snapshot.data,
          style: FontHelper.regular(Colors.black, 14.0),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

class _DeliveryLocation extends StatelessWidget {
  final Order order;

  const _DeliveryLocation({Key key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Deliver To:",
          style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
          textAlign: TextAlign.center,
        ),
        Row(
          children: <Widget>[
            ConstrainedBox(
              child: StreamBuilder<String>(
                stream: order.deliveryLocationDescription,
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Offstage();
                  }
                  return Text(
                    snapshot.data,
                    style: FontHelper.regular(Colors.black, 14.0),
                    textAlign: TextAlign.right,
                  );
                },
              ),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 2),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0),
              child: GestureDetector(
                  child: Image.asset('assets/icons/google-maps.png'),
                  onTap: () {
                    LatLng temp = LatLng(order.deliveryLocation.value.latitude,
                        order.deliveryLocation.value.longitude);
                    launchMaps(temp);
                  }),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderItems extends StatelessWidget {
  final Order order;
  final MutableProperty<List<OrderItem>> listOfOrderItems;

  const _OrderItems({Key key, this.order, this.listOfOrderItems }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildFoodTagHeader(),
        buildOrderItemsList(),
        buildDeliveryFee(),
        buildPromo(),
      ],
    );
  }

  Widget buildOrderItemsList() {
    return StreamBuilder<List<OrderItem>>(
      stream:listOfOrderItems.producer,
      builder: (context, snap) {
        List<Widget> listOfWidget = List();
        if (!snap.hasData || snap.data == null)
          return Center(
            child: CircularProgressIndicator(),
          );
        snap.data.forEach(
            (orderItem) => listOfWidget.add(buildOrderItemCell(orderItem)));
        return Column(
          children: listOfWidget,
        );
      },
    );
  }

  Widget buildOrderItemCell(OrderItem orderItem) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 55),
      child: Container(
        padding: EdgeInsets.only(top: 5, left: 5, right: 5),
        color: Colors.white,
        margin: EdgeInsets.only(top: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 30.0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${orderItem.quantity.value} x",
                    style: FontHelper.semiBold12Black,
                  ),
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
                    style: FontHelper.semiBold(ColorHelper.dabaoOffBlack4A, 10),
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
    );
  }

  Widget buildDeliveryFee() {
    return StreamBuilder<double>(
      stream: order.deliveryFee,
      builder: (context, snap) {
        if (!snap.hasData || snap.data == null) return Offstage();

        return Container(
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Delivery Fee Selected", style: FontHelper.regular14Black),
              Text(StringHelper.doubleToPriceString(snap.data),
                  style: FontHelper.regular12Black),
            ],
          ),
        );
      },
    );
  }

  Widget buildPromo() {
    return StreamBuilder<double>(
      stream: order.deliveryFeeDiscount,
      builder: (context, snap) {
        if (!snap.hasData || snap.data == null) return Offstage();

        return Container(
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Promo Code", style: FontHelper.regular14Black),
              Text("- " + StringHelper.doubleToPriceString(snap.data),
                  style: FontHelper.regular12Black),
            ],
          ),
        );
      },
    );
  }

  Widget buildFoodTagHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        StreamBuilder<String>(
          stream: order.foodTag,
          builder: (context, snap) {
            if (!snap.hasData || snap.data == null) return Offstage();
            return Row(
              children: <Widget>[
                Text("Pick Up from:  ",
                    style:
                        FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 12)),
                Text(
                  StringHelper.upperCaseWords(snap.data),
                  style: FontHelper.regular14Black,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
        StreamBuilder<int>(
            stream: listOfOrderItems.producer.map(
                (orderItems) => orderItems == null ? null : orderItems.length),
            builder: (context, snap) {
              if (!snap.hasData || snap.data == null) return Offstage();

              return Text(
                "${snap.data} item(s)",
                style: FontHelper.regular14Black,
              );
            }),
      ],
    );
  }
}
