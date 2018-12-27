import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/ViewOrdersTabPages/OrderList.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Matches extends StatefulWidget {

  final DabaoRoute.Route route;

  Matches({Key key, @required this.route}) : super(key: key);

  @override
  MatchesState createState() {
    return new MatchesState();
  }
}

class MatchesState extends State<Matches> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(automaticallyImplyLeading: true, title: Text(
          'MATCHES',
          style: FontHelper.header3TextStyle,
        ),),
        body: OrderList(
          context: context,
          route: widget.route,
          input: widget.route.listOfPotentialOrders,
          location: widget.route.deliveryLocation.value.map((geopoint)=> LatLng(geopoint.latitude, geopoint.longitude)).first,
        ),
      
    );
  }
}