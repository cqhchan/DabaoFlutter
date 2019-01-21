import 'dart:io';

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
  final Function(int tab) moveToTab;
  const BrowseOrderTabView({Key key, this.moveToTab}) : super(key: key);

  _BrowseOrderTabViewState createState() => _BrowseOrderTabViewState();
}

class _BrowseOrderTabViewState extends State<BrowseOrderTabView>
    with
        HavingGoogleMapPlaces,
        HavingSubscriptionMixin,
        AutomaticKeepAliveClientMixin<BrowseOrderTabView> {
  @override
  bool get wantKeepAlive => true;

  final MutableProperty<List<Order>> searchOrders =
      MutableProperty<List<Order>>(null);
  final MutableProperty<List<Order>> defaultOrders =
      MutableProperty<List<Order>>(null);
  MutableProperty<LatLng> searchLocation;
  MutableProperty<int> searchRadius;
  MutableProperty<String> locationDescription = MutableProperty<String>(null);

  final MutableProperty<bool> isSearchingLocation = MutableProperty(false);
  final String searchLocationPlaceholder = "Select Location";
  String searchText;

  @override
  void initState() {
    super.initState();

    subscription.add(locationDescription.producer.listen((location) {
      setState(() {
        searchText = location;
      });
    }));

    searchText = searchLocationPlaceholder;

    searchLocation = MutableProperty(null);

    searchRadius = MutableProperty(500);

    subscription.add(defaultOrders.bindTo(FirebaseCollectionReactive<Order>(
            Firestore.instance
                .collection("orders")
                .where(Order.startTimeKey,
                    isGreaterThanOrEqualTo:
                        DateTime.now().add(Duration(days: -7)))
                .where(Order.statusKey, isEqualTo: orderStatus_Requested)
                .limit(20))
        .observable));

    subscription.add(searchOrders.bindTo(searchLocation.producer
        .switchMap((latlng) => searchRadius.producer.switchMap((radius) =>
            FirebaseCloudFunctions.fetchProximityHash(
                    location: latlng, radius: radius)
                .asStream()))
        .map((hashes) {
      return hashes.map((hash) {
        return FirebaseCollectionReactive<Order>(Firestore.instance
                .collection("orders")
                .where(Order.geoHashKey, isGreaterThanOrEqualTo: hash)
                .where(Order.geoHashKey, isLessThanOrEqualTo: hash + "zzzzzzzz")
                .where(Order.statusKey, isEqualTo: orderStatus_Requested))
            .observable;
      }).toList();
    }).switchMap((list) {
      return combineAndMerge<Order>(list);
    })));
  }

  @override
  void dispose() {
    if (searchOrders.value != null) Selectable.deselectAll(searchOrders.value);

    if (defaultOrders.value != null)
      Selectable.deselectAll(defaultOrders.value);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: ColorHelper.dabaoOffWhiteF5,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(7.0, 12.0, 7.0, 0.0),
            height: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    // test.add(List.generate(1, (i)=> 30));
                    handlePressButton(
                        context,
                        searchLocation,
                        locationDescription,
                        searchText == searchLocationPlaceholder
                            ? ""
                            : searchText, (){
                              isSearchingLocation.value = true;
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
                        Expanded(
                          child: Text(
                            searchText,
                            style: FontHelper.regular(Colors.black, 12.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                )),
                Offstage(
                  offstage: !isSearchingLocation.value,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          isSearchingLocation.value = false;
                          searchText = searchLocationPlaceholder;
                          searchOrders.value = null;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: StreamBuilder(
            stream: isSearchingLocation.producer
                .switchMap((searchingLocation) => searchingLocation
                    ? searchOrders.producer
                    : defaultOrders.producer)
                .map((orders) {
              List<Order> tempOrders = List.from(orders);
              tempOrders.removeWhere((order) =>
                  order.creator.value ==
                  ConfigHelper.instance.currentUserProperty.value.uid);

              tempOrders.sort((lhs, rhs) => rhs.createdDeliveryTime.value
                  .compareTo(lhs.createdDeliveryTime.value));

              return tempOrders;
            }),
            builder: (context, snap) {
              if (!snap.hasData)
                return Center(child: CircularProgressIndicator());

              print("testing order list" + snap.data.length.toString());

              return OrderList(
                onCompleteCallBack: () {
                  if (widget.moveToTab != null) {
                    widget.moveToTab(1);
                  }
                },
                context: context,
                input: isSearchingLocation.producer
                    .switchMap((searchingLocation) => searchingLocation
                        ? searchOrders.producer
                        : defaultOrders.producer)
                    .map((orders) {
                  List<Order> tempOrders = List.from(orders);
                  tempOrders.removeWhere((order) =>
                      order.creator.value ==
                      ConfigHelper.instance.currentUserProperty.value.uid);

                  tempOrders.sort((lhs, rhs) => rhs.createdDeliveryTime.value
                      .compareTo(lhs.createdDeliveryTime.value));

                  return tempOrders;
                }),
                location: ConfigHelper.instance.currentLocationProperty.value,
                refresh: (context) async {
                  try {
                    final result = await InternetAddress.lookup('google.com');
                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                      disposeAndReset();

                      subscription.add(defaultOrders.bindTo(
                          FirebaseCollectionReactive<Order>(Firestore.instance
                                  .collection("orders")
                                  .where(Order.startTimeKey,
                                      isGreaterThanOrEqualTo: DateTime.now()
                                          .add(Duration(days: -7)))
                                  .where(Order.statusKey,
                                      isEqualTo: orderStatus_Requested)
                                  .limit(20))
                              .observable));

                      subscription.add(searchOrders.bindTo(searchLocation
                          .producer
                          .switchMap((latlng) => searchRadius.producer
                              .switchMap((radius) =>
                                  FirebaseCloudFunctions.fetchProximityHash(
                                          location: latlng, radius: radius)
                                      .asStream()))
                          .map((hashes) {
                        return hashes.map((hash) {
                          return FirebaseCollectionReactive<Order>(Firestore
                                  .instance
                                  .collection("orders")
                                  .where(Order.geoHashKey,
                                      isGreaterThanOrEqualTo: hash)
                                  .where(Order.geoHashKey,
                                      isLessThanOrEqualTo: hash + "zzzzzzzz")
                                  .where(Order.statusKey,
                                      isEqualTo: orderStatus_Requested))
                              .observable;
                        }).toList();
                      }).switchMap((list) {
                        return combineAndMerge<Order>(list);
                      })));
                      return Future.delayed(Duration(seconds: 2));
                    }

                    print('not connected');
                    final snackBar = SnackBar(
                        content: Text(
                            'An Error has occured. Please check your network connectivity'));
                    Scaffold.of(context).showSnackBar(snackBar);
                  } on SocketException catch (_) {
                    print('not connected');
                    final snackBar = SnackBar(
                        content: Text(
                            'An Error has occured. Please check your network connectivity'));
                    Scaffold.of(context).showSnackBar(snackBar);
                  }

                  return Future.delayed(Duration(seconds: 1));
                },
              );
            },
          )),
        ],
      ),
    );
  }
}
