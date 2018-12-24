import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:flutterdabao/Model/User.dart';

class MyRouteTabView extends StatefulWidget {
  _MyRouteTabViewState createState() => _MyRouteTabViewState();
}

class _MyRouteTabViewState extends State<MyRouteTabView> {
  final MutableProperty<List<DabaoRoute.Route>> userRequestedOrders =
      ConfigHelper.instance.currentUserOpenRoutesProperty;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DabaoRoute.Route>>(
      stream: userRequestedOrders.producer,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return Text('No Routes Avaliable');
        return _buildList(context, snapshot.data);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DabaoRoute.Route> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _RouteCell(route: data)).toList(),
    );
  }
}

class _RouteCell extends StatefulWidget {
  final DabaoRoute.Route route;

  const _RouteCell({Key key, @required this.route}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RouteCellState();
  }
}

class _RouteCellState extends State<_RouteCell> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(10.0),
      color: Colors.white,
      elevation: 6.0,
      child: Container(
        padding: EdgeInsets.fromLTRB(15.0, 12.0, 18.0, 12.0),
        child: Column(
          children: <Widget>[
            buildHeaderRow(),
            buildStartLocation(),
            buildDottedLine(),
            buildListOfAcceptedOrders(),
            buildDeliveryLocation(),
            Line(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
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

  Row buildPossibleMatches() {
    return Row(
      children: <Widget>[
        StreamBuilder<List<User>>(
          stream: widget.route.listOfPotentialOrders.map((orders) {
            return orders
                .take(3)
                .map((order) => User.fromUID(order.creator.value))
                .toList();
          }),
          builder: (context, snap) {
            return Stack(
              children: <Widget>[
                snap.data == null || snap.data.length <= 2
                    ? Image.asset("assets/icons/filler_image_girl.png")
                    : StreamBuilder<String>(
                        stream: snap.data.elementAt(2).thumbnailImage,
                        builder: (context, snap) {
                          if (!snap.hasData)
                            return Image.asset(
                                "assets/icons/filler_image_girl.png");

                          return Container(
                              height: 30.0,
                              width: 30.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(snap.data))));
                        },
                      ),
                Container(
                    margin: EdgeInsets.only(left: 17.0),
                    child: snap.data == null || snap.data.length <= 1
                        ? Image.asset("assets/icons/filler_image_girl.png")
                        : StreamBuilder<String>(
                            stream: snap.data.elementAt(1).thumbnailImage,
                            builder: (context, snap) {
                              if (!snap.hasData)
                                return Image.asset(
                                    "assets/icons/filler_image_girl.png");

                              return Container(
                                  height: 30.0,
                                  width: 30.0,
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.fill,
                                          image: new NetworkImage(snap.data))));
                            },
                          )),
                Container(
                    margin: EdgeInsets.only(left: 34.0),
                    child: snap.data == null || snap.data.length == 0
                        ? Image.asset("assets/icons/filler_image_girl.png")
                        : StreamBuilder<String>(
                            stream: snap.data.elementAt(0).thumbnailImage,
                            builder: (context, snap) {
                              if (!snap.hasData)
                                return Image.asset(
                                    "assets/icons/filler_image_girl.png");

                              return Container(
                                  height: 30.0,
                                  width: 30.0,
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.fill,
                                          image: new NetworkImage(snap.data))));
                            },
                          )),
              ],
            );
          },
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10.0,
          ),
          child: StreamBuilder<List<Order>>(
            stream: widget.route.listOfPotentialOrders,
            builder: (context, snap) => snap.hasData && snap.data.length > 0
                ? Text(
                    "${snap.data.length} matches for Your Route!",
                    style: FontHelper.semiBold14Black,
                  )
                : Text("No Matches Found for this Route",
                    style: FontHelper.semiBold14Black),
          ),
        ),
        Flexible(
          child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset("assets/icons/arrow_right_black_outline.png")),
        )
      ],
    );
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
            padding: EdgeInsets.only(left: 12.0, right: 20.0),
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
            padding: EdgeInsets.only(left: 12.0, right: 20.0),
            child: StreamBuilder<List<String>>(
                stream: widget.route.deliveryLocationDescription,
                builder: (context, snap) {
                  if (!snap.hasData || snap.data.first == null)
                    return CircularProgressIndicator();
                  return Text(
                    snap.data.first,
                    style: FontHelper.regular14Black,
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget buildOrderDeliveryLocation(Order order) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
                alignment: Alignment.topLeft,
                child: Container(child: Image.asset("assets/icons/pin.png"))),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 12.0, right: 20.0),
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
                            style: FontHelper.regular(ColorHelper.dabaoOffBlack9B, 12.0),
                          );
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
        buildDottedLine(),
      ],
    );
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
            child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    padding: EdgeInsets.only(top: 8.0),
                    child:
                        Image.asset("assets/icons/dotted_line_circular.png"))))
      ],
    );
  }
}
