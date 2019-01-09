import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
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

class MatchesState extends State<Matches> with HavingSubscriptionMixin {
  MutableProperty<List<Order>> listOfPotentialMatches = MutableProperty(List());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  listOfPotentialMatches =widget.route.listOfPotentialOrders;
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          'MATCHES',
          style: FontHelper.header3TextStyle,
        ),
      ),
      body: OrderList(
        context: context,
        route: widget.route,
        input: listOfPotentialMatches.producer,
        location: widget.route.deliveryLocation.value
            .map((geopoint) => LatLng(geopoint.latitude, geopoint.longitude))
            .first,
      ),
    );
  }
}
