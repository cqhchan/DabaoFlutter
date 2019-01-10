import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/ViewOrdersTabPages/EditFoodTag.dart';
import 'package:flutterdabao/ViewOrdersTabPages/Matches.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';

class MyRouteTabView extends StatefulWidget {
  const MyRouteTabView({Key key}) : super(key: key);

  _MyRouteTabViewState createState() => _MyRouteTabViewState();
}

class _MyRouteTabViewState extends State<MyRouteTabView>
    with
        AutomaticKeepAliveClientMixin<MyRouteTabView>,
        HavingSubscriptionMixin {
  @override
  bool get wantKeepAlive => true;

  final MutableProperty<List<DabaoRoute.Route>> userRoutes =
      ConfigHelper.instance.currentUserRoutesPastDayProperty;

  final MutableProperty<List<Order>> userDeliveryingOrders =
      ConfigHelper.instance.currentUserDeliveringOrdersProperty;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        color: ColorHelper.dabaoOffWhiteF5,
        child: StreamBuilder<List<Object>>(
          stream: Observable.combineLatest2<List<DabaoRoute.Route>, List<Order>,
                  List<Object>>(userRoutes.producer,
              userDeliveryingOrders.producer.map((orders) {
            List<Order> tempOrders = List.from(orders);
            // tempOrders.removeWhere((order) => order.routeID.value != null);
            return tempOrders;
          }), (openRoutes, orders) {
            List<Object> temp = List();

            List<DabaoRoute.Route> tempRoutes = List();


            if (openRoutes != null && openRoutes.length != 0)
              tempRoutes.addAll(openRoutes);


            tempRoutes.sort((lhs, rhs) =>
                rhs.deliveryTime.value.compareTo(lhs.deliveryTime.value));


            temp.addAll(tempRoutes);
            if (orders != null && orders.length != 0) temp.add(orders);

            return temp;
          }),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (!snapshot.hasData)
              return Center(child: Text('No Routes Avaliable'));
            return _buildList(context, snapshot.data);
          },
        ));
  }

  Widget _buildList(BuildContext context, List<Object> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 30.0),
      children: snapshot.map((data) {
        if (data is DabaoRoute.Route) return _RouteCell(route: data);
        if (data is List<Order>) return _OrdersCell(orders: data);
        return Container();
      }).toList(),
    );
  }
}

class _RouteCell extends StatefulWidget {
  final DabaoRoute.Route route;

  const _RouteCell({Key key, @required this.route}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RouteCellState();
  }
}

class _RouteCellState extends State<_RouteCell> with HavingSubscriptionMixin {
  MutableProperty<List<Order>> listOfPotentialMatches = MutableProperty(List());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listOfPotentialMatches = widget.route.listOfPotentialOrders;
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.all(10.0),
        color: Colors.white,
        elevation: 6.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(15.0, 12.0, 10.0, 12.0),
          child: Column(
            children: <Widget>[
              buildHeaderRow(),
              buildStartLocation(),
              buildDottedLine(),
              buildListOfAcceptedOrders(),
              buildDeliveryLocation(),
              Line(
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 8.0),
              ),
              buildPossibleMatches()
            ],
          ),
        ),
    
    );
  }

  StreamBuilder<List<Order>> buildListOfAcceptedOrders() {
    return StreamBuilder<List<Order>>(
      stream: widget.route.listOfOrdersAccepted.producer,
      builder: (context, snap) {
        if (!snap.hasData || snap.data.length == 0) return Container();

        List<Widget> listOfWidget = snap.data
            .map((order) => buildOrderDeliveryLocation(order))
            .toList();

        return Column(
          children: listOfWidget,
        );
      },
    );
  }

  Widget buildPossibleMatches() {
    return StreamBuilder<String>(
        stream: widget.route.status,
        builder: (context, snap) {
          if (!snap.hasData ||
              snap.data == null ||
              snap.data == DabaoRoute.routeStatus_Open)
            return Container(
              margin: EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  StreamBuilder<List<User>>(
                    stream: listOfPotentialMatches.producer.map((orders) {
                      return orders
                          .take(3)
                          .map((order) => User.fromUID(order.creator.value))
                          .toList();
                    }),
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data.length == 0)
                        return Offstage();

                      return Stack(
                        children: <Widget>[
                          snap.data == null || snap.data.length <= 2
                              ? Image.asset(
                                  "assets/icons/filler_image_girl.png")
                              : StreamBuilder<String>(
                                  stream: snap.data.elementAt(2).thumbnailImage,
                                  builder: (context, snap) {
                                    if (!snap.hasData)
                                      return Image.asset(
                                          "assets/icons/filler_image_girl.png");
                                    return FittedBox(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CachedNetworkImage(
                                            imageUrl: snap.data,
                                            placeholder:
                                                GlowingProgressIndicator(
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
                          Container(
                              margin: EdgeInsets.only(left: 17.0),
                              child: snap.data == null || snap.data.length <= 1
                                  ? Image.asset(
                                      "assets/icons/filler_image_food.png")
                                  : StreamBuilder<String>(
                                      stream:
                                          snap.data.elementAt(1).thumbnailImage,
                                      builder: (context, snap) {
                                        if (!snap.hasData)
                                          return Image.asset(
                                              "assets/icons/filler_image_food.png");
                                        return FittedBox(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            child: SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: CachedNetworkImage(
                                                imageUrl: snap.data,
                                                placeholder:
                                                    GlowingProgressIndicator(
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
                                    )),
                          Container(
                              margin: EdgeInsets.only(left: 34.0),
                              child: snap.data == null || snap.data.length == 0
                                  ? Image.asset(
                                      "assets/icons/filler_image_girl.png")
                                  : StreamBuilder<String>(
                                      stream:
                                          snap.data.elementAt(0).thumbnailImage,
                                      builder: (context, snap) {
                                        if (!snap.hasData)
                                          return Image.asset(
                                              "assets/icons/filler_image_girl.png");
                                        return FittedBox(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            child: SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: CachedNetworkImage(
                                                imageUrl: snap.data,
                                                placeholder:
                                                    GlowingProgressIndicator(
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
                                    )),
                        ],
                      );
                    },
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 10.0, minWidth: 5.0),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(),
                      child: StreamBuilder<List<Order>>(
                        stream: listOfPotentialMatches.producer,
                        builder: (context, snap) =>
                            snap.hasData && snap.data.length > 0
                                ? Text(
                                    "${snap.data.length} matches for Your Route!",
                                    style: FontHelper.semiBold14Black,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    "No Matches Found for this Route",
                                    style: FontHelper.semiBold14Black,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: StreamBuilder<List<Order>>(
                          stream: listOfPotentialMatches.producer,
                          builder: (context, snap) => snap.hasData &&
                                  snap.data.length > 0
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Matches(
                                                  route: widget.route,
                                                )));
                                  },
                                  child: Image.asset(
                                      "assets/icons/arrow_right_black_outline.png"))
                              : Container(
                                  height: 30,
                                ))),
                ],
              ),
            );
          else
            return Container(
              height: 30,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "This Route is closed",
                  style: FontHelper.semiBold14Black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
        });
  }

  Align buildDottedLine() => Align(
      alignment: Alignment.centerLeft,
      child: Container(
          padding: EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
          child: Image.asset("assets/icons/dotted_line_straight.png")));

  Row buildStartLocation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Image.asset("assets/icons/blue_marker.png"),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 12.0, right: 28.0),
            child: StreamBuilder<String>(
              stream: widget.route.startLocationDescription,
              builder: (context, snap) {
                if (!snap.hasData || snap.data == null)
                  return CircularProgressIndicator();
                return Text(
                  snap.data,
                  style: FontHelper.regular14Black,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Row buildDeliveryLocation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Image.asset("assets/icons/red_marker_icon.png"),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 12.0, right: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StreamBuilder<List<String>>(
                    stream: widget.route.deliveryLocationDescription,
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data.first == null)
                        return CircularProgressIndicator();
                      return Text(
                        snap.data.first,
                        style: FontHelper.regular14Black,
                      );
                    }),
                StreamBuilder<DateTime>(
                    stream: widget.route.deliveryTime,
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data == null)
                        return CircularProgressIndicator();
                      return Text(
                        "Arriving at " +
                            DateTimeHelper.convertTimeToDisplayString(
                                snap.data),
                        style: FontHelper.regular(
                            ColorHelper.dabaoOffBlack9B, 12.0),
                      );
                    })
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOrderDeliveryLocation(Order order) {
    return Column(
      children: <Widget>[
        new _OrderWidget(
          order: order,
        ),
        buildDottedLine(),
      ],
    );
  }

  showOverlay() {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return EditFoodTagOverlay(
            route: widget.route
          );
        });
  }

  Row buildHeaderRow() {
    return Row(
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Your Route",
            style: FontHelper.semiBold16(ColorHelper.dabaoOffBlack4A),
          ),
        ),
        StreamBuilder<List<Order>>(
          stream: widget.route.listOfOrdersAccepted.producer,
          builder: (context, snap) {
            if (!snap.hasData || snap.data.length == 0) return Container();

            return Container(
              padding: EdgeInsets.only(left: 15.0, top: 1.0),
              child: Text("${snap.data.length} other Locations(s)",
                  style: FontHelper.regular(ColorHelper.dabaoOffBlack9B, 12.0)),
            );
          },
        ),
        Expanded(
            child: Stack(
          children: <Widget>[
            Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    padding: EdgeInsets.only(top: 8.0, right: 8.0),
                    child:
                        Image.asset("assets/icons/dotted_line_circular.png"))),
            Align(
              alignment: Alignment.bottomRight,
              child: StreamBuilder<String>(
                  stream: widget.route.status,
                  builder: (context, snap) {
                    if (!snap.hasData ||
                        snap.data == null ||
                        snap.data == DabaoRoute.routeStatus_Open)
                      return DropdownButtonHideUnderline(
                          child: ConstrainedBox(
                        child: DropdownButton<String>(
                          iconSize: 0.0,
                          items: <String>['Edit Tags', 'Close']
                              .map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(
                                value,
                                style: FontHelper.regular14Black,
                              ),
                            );
                          }).toList(),
                          onChanged: (chosen) {
                            if (chosen == "Edit Tags") {
                              showOverlay();
                            } else {
                              widget.route.closeRoute();
                            }
                          },
                        ),
                        constraints: BoxConstraints(maxHeight: 25),
                      ));

                    return DropdownButtonHideUnderline(
                        child: ConstrainedBox(
                      child: DropdownButton<String>(
                        iconSize: 0.0,
                        items:
                            <String>['Open'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(
                              value,
                              style: FontHelper.regular14Black,
                            ),
                          );
                        }).toList(),
                        onChanged: (chosen) {
                  
                            widget.route.openRoute();
                        
                        },
                      ),
                      constraints: BoxConstraints(maxHeight: 25),
                    ));
                  }),
            ),
          ],
        ))
      ],
    );
  }
}

class _OrdersCell extends StatefulWidget {
  final List<Order> orders;

  const _OrdersCell({Key key, this.orders}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OrderCellState();
  }
}

class _OrderCellState extends State<_OrdersCell> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listOfOrders = List();
    listOfOrders.add(buildHeaderRow());
    widget.orders.forEach((order) {
      listOfOrders.add(_OrderWidget(
        order: order,
      ));
      listOfOrders.add(buildDottedLine());
    });

    listOfOrders.removeLast();

    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.all(10.0),
        color: Colors.white,
        elevation: 6.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(15.0, 12.0, 18.0, 12.0),
          child: Column(
            children: listOfOrders,
          ),
        ));
  }

  Row buildHeaderRow() {
    return Row(
      children: <Widget>[
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Other",
            style: FontHelper.semiBold16(ColorHelper.dabaoOffBlack4A),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15.0, top: 1.0),
          child: Text("${widget.orders.length} Locations(s)",
              style: FontHelper.regular(ColorHelper.dabaoOffBlack9B, 12.0)),
        ),
        Expanded(
            child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    padding: EdgeInsets.only(top: 8.0),
                    child:
                        Image.asset("assets/icons/dotted_line_circular.png"))))
      ],
    );
  }

  Align buildDottedLine() => Align(
      alignment: Alignment.centerLeft,
      child: Container(
          padding: EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
          child: Image.asset("assets/icons/dotted_line_straight.png")));
}

class _OrderWidget extends StatelessWidget {
  final Order order;
  const _OrderWidget({
    Key key,
    @required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
            alignment: Alignment.topLeft,
            child: Container(child: Image.asset("assets/icons/pin.png"))),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 12.0, right: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StreamBuilder<String>(
                    stream: order.deliveryLocationDescription,
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data == null)
                        return CircularProgressIndicator();
                      return Text(
                        snap.data,
                        style: FontHelper.regular14Black,
                      );
                    }),
                StreamBuilder<DateTime>(
                    stream: order.deliveryTime,
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data == null)
                        return CircularProgressIndicator();
                      return Text(
                        "Deliver at " +
                            DateTimeHelper.convertTimeToDisplayString(
                                snap.data),
                        style: FontHelper.regular(
                            ColorHelper.dabaoOffBlack9B, 12.0),
                      );
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
