import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMapPlaces.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/ViewOrdersTabPages/OrderList.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class BrowseOrderTabView extends StatefulWidget {

  const BrowseOrderTabView({Key key}): super(key: key);

  _BrowseOrderTabViewState createState() => _BrowseOrderTabViewState();
}

class _BrowseOrderTabViewState extends State<BrowseOrderTabView>
    with HavingGoogleMapPlaces, HavingSubscriptionMixin, AutomaticKeepAliveClientMixin<BrowseOrderTabView> {
      
  @override
  bool get wantKeepAlive => true;


  MutableProperty<List<Order>> searchOrders =
      MutableProperty<List<Order>>(List());
  BehaviorSubject<LatLng> searchLocation;
  BehaviorSubject<int> searchRadius;

  String searchText = "Current Location";

  @override
  void initState() {
    super.initState();

    searchLocation = BehaviorSubject(
        seedValue: ConfigHelper.instance.currentLocationProperty.value);

    searchRadius = BehaviorSubject(seedValue: 500);

    subscription.add(searchOrders.bindTo(searchLocation
        .switchMap((latlng) => searchRadius.switchMap((radius) =>
            FirebaseCloudFunctions.fetchProximityHash(
                    location: latlng, radius: radius)
                .asStream()))
        .map((hashes) {
      return hashes.map((hash) {
        return FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.geoHashKey, isGreaterThanOrEqualTo: hash)
                .where(Order.geoHashKey, isLessThanOrEqualTo: hash + "z")
                .where(Order.statusKey, isEqualTo: orderStatus_Requested))
            .observable;
      }).toList();
    }).switchMap((list) {
      return combineAndMerge<Order>(list);
    }).map((orders) {
      orders.removeWhere((order) =>
          order.creator.value ==
          ConfigHelper.instance.currentUserProperty.value.uid);
      return orders;
    })));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Selectable.deselectAll(searchOrders.value);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(7.0, 12.0, 7.0, 0.0),
            height: 30,
            child: Row(
              children: <Widget>[
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    // test.add(List.generate(1, (i)=> 30));
                    handlePressButton(context, (location, description) {
                      searchLocation.add(location);
                      setState(() {
                        searchText = description;
                      });
                    });
                  },
                  child: Container(
                    height: 30.0,
                    decoration: BoxDecoration(
                        color: ColorHelper.rgbo(0xD0, 0xD0, 0xD0),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Row(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(left: 7, right: 10.0),
                            child: Image.asset(
                              "assets/icons/search_icon.png",
                              color: ColorHelper.dabaoOffBlack9B,
                            )),
                        Text(
                          searchText,
                          style: FontHelper.regular(Colors.black, 12.0),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                )),
                Container(
                  height: 30.0,
                  margin: EdgeInsets.only(left: 3.0),
                  width: 155,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1.0,
                          color: ColorHelper.rgbo(0xD0, 0xD0, 0xD0)),
                      color: ColorHelper.rgbo(0xF5, 0xE4, 0xC6),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 7.0),
                          child: Text(
                            "Distance from Location",
                            style: FontHelper.regular(ColorHelper.dabaoOffGrey70, 12.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 5, right: 7.0),
                          child: Image.asset(
                            "assets/icons/filter_icon.png",
                            color: ColorHelper.dabaoOffBlack9B,
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: OrderList(
              context: context,
              input: searchOrders.producer,
              location: ConfigHelper.instance.currentLocationProperty.value,
            ),
          ),
        ],
      ),
    );
  }
}
