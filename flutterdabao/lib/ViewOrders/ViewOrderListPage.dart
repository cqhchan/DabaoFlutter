import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/ChatNavigationButton.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/ViewOrders/ViewOrderPage.dart';
import 'package:rxdart/rxdart.dart';

class ViewOrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ViewOrdersPageState();
  }
}

class ViewOrdersPageState extends State<ViewOrderListPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: ColorHelper.dabaoOffWhiteF5,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Your Orders', style: FontHelper.header3TextStyle),
        actions: <Widget>[
          ChatNavigationButton(),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: Observable.combineLatest3<List<Order>, List<Order>,
                  List<Order>, List<Object>>(
              ConfigHelper.instance.currentUserAcceptedOrdersProperty.producer,
              ConfigHelper.instance.currentUserRequestedOrdersProperty.producer,
              ConfigHelper.instance.currentUserPastWeekCompletedOrdersProperty
                  .producer, (accepted, requested, completed) {
            List<Object> objectsList = List();

            List<Order> tempAccepted = List.from(accepted);
            List<Order> tempRequested = List.from(requested);
            List<Order> tempCompleted = List.from(completed);

            tempAccepted.sort((lhs, rhs) =>
                rhs.deliveryTime.value.compareTo(lhs.deliveryTime.value));
            tempRequested.sort((lhs, rhs) => rhs.startDeliveryTime.value
                .compareTo(lhs.startDeliveryTime.value));

            tempCompleted.sort((lhs, rhs) =>
                rhs.completedTime.value.compareTo(lhs.completedTime.value));

            objectsList.add(
                "CURRENT ORDERS (${tempAccepted.length + tempRequested.length})");
            // objectsList.addAll(tempAccepted);
            objectsList.addAll(tempAccepted);

            objectsList.addAll(tempRequested);

            if (tempCompleted.length > 0) {
              objectsList.add(null);
              objectsList.add("COMPLETED ORDERS (${tempCompleted.length})");
              objectsList.addAll(tempCompleted);
            }

            return objectsList;
          }),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null)
              return Center(child: CircularProgressIndicator());

            return ListView.builder(
              itemBuilder: (context, index) {
                if (snapshot.data[index] is Order)
                  return _ViewOrderCell(
                    order: snapshot.data[index] as Order,
                  );

                if (snapshot.data[index] is String)
                  return buildHeader(snapshot.data[index]);

                return Container(
                  height: 20,
                );
              },
              itemCount: snapshot.data.length,
            );
          },
        ),
      ),
    );
  }

  Widget buildHeader(String headerText) {
    return Container(
      height: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 10.0, bottom: 2),
              child: Text(
                headerText,
                style: FontHelper.regular(ColorHelper.dabaoOffGrey70, 12,
                    letterSpacing: 2.0),
              )),
          Line(),
        ],
      ),
    );
  }
}

class _ViewOrderCell extends StatefulWidget {
  final Order order;

  const _ViewOrderCell({Key key, this.order}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewOrderCellState();
  }
}

class _ViewOrderCellState extends State<_ViewOrderCell> with HavingSubscriptionMixin {

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
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(FadeRoute(
              widget: DabaoeeViewOrderListPage(
            order: widget.order,
          )));
        },
        child: Container(
          color: Colors.transparent,
          height: 80,
          child: orderCell(widget.order),
        ));
  }

  Widget orderCell(Order order) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 5, top: 0, bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: orderStatus(order)),
                        Expanded(child: foodTagHeader(order)),
                        Expanded(child: orderItemsAndPrice(order)),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      deliveryTime(order),
                      Expanded(
                        child: Container(
                            width: 40,
                            color: Colors.transparent,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: ColorHelper.dabaoOffGrey70,
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Line(),
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

  StreamBuilder<String> deliveryTime(Order order) {
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
          style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 10.0),
          textAlign: TextAlign.right,
        );
      },
    );
  }

  Widget orderItemsAndPrice(Order order) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.only(left: 2.0),
        child: StreamBuilder<List<OrderItem>>(
            stream: listOfOrderItems.producer,
            builder: (context, snap) {
              if (!snap.hasData || snap.data == null || snap.data.length  == 0 ) return Offstage();

              int totalItems = snap.data
                  .map((orderItem) => orderItem.quantity.value)
                  .reduce((lhs, rhs) => lhs + rhs);

              double totalPrice = snap.data
                  .map((orderItem) =>
                      orderItem.quantity.value * orderItem.price.value)
                  .reduce((lhs, rhs) => lhs + rhs);

              return Text(
                "Your Order: ${totalItems} items • ${StringHelper.doubleToPriceString(totalPrice)}",
                style: FontHelper.regular(ColorHelper.dabaoOffBlack9B, 12.0),
              );
            }),
      ),
    );
  }

  Widget foodTagHeader(Order order) {
    return Container(
      padding: EdgeInsets.only(left: 2.0),
      child: StreamBuilder<String>(
          stream: order.foodTag,
          builder: (context, snap) {
            return Text(
              (snap.hasData && snap.data != null)
                  ? StringHelper.upperCaseWords(snap.data)
                  : "Error",
              style: FontHelper.semiBold14Black,
            );
          }),
    );
  }

}
