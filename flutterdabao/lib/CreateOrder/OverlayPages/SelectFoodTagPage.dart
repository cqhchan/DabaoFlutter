import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/FoodTags/SearchFoodTag.dart';
import 'package:flutterdabao/FoodTags/TagWrap.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

// Page 0 in Overlays
// 3segments, My orders, places near me and Being Delivered near you
class SelectFoodTagPage extends StatefulWidget {
  final OrderHolder holder;
  final VoidCallback nextPage;

  SelectFoodTagPage({Key key, @required this.holder, @required this.nextPage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectFoodTagPageState();
  }
}

class _SelectFoodTagPageState extends State<SelectFoodTagPage>
    with HavingSubscriptionMixin {
  final MutableProperty<List<FoodTag>> reccomendedFoodTags =
      MutableProperty(null);
  final MutableProperty<List<FoodTag>> deliveredNearbyFoodTags =
      MutableProperty(null);

  LatLng lastSearchLatLng;

  final MutableProperty<List<FoodTag>> userFoodTags =
      ConfigHelper.instance.currentUserFoodTagsProperty;

  @override
  void initState() {
    super.initState();

    subscription
        .add(widget.holder.deliveryLocation.producer.listen((location) async {
      if (lastSearchLatLng == null || lastSearchLatLng != location)
        FirebaseCloudFunctions.fetchNearbyFoodTags(
                location: location, radius: 1500)
            .then((list) {
          reccomendedFoodTags.value = list;
        });
    }));

    Observable.combineLatest2<LatLng, OrderMode, LatLng>(
        widget.holder.deliveryLocation.producer, widget.holder.mode.producer,
        (location, mode) {
      return location;
    }).listen((location) {
      switch (widget.holder.mode.value) {
        case OrderMode.asap:
          FirebaseCloudFunctions.fetchNearbyDeliveryFoodTags(
                  location: location,
                  startTime: DateTime.now(),
                  endTime: widget.holder.endDeliveryTime.value)
              .then((list) {
            deliveredNearbyFoodTags.value = list;
          });
          break;

        case OrderMode.scheduled:
          FirebaseCloudFunctions.fetchNearbyDeliveryFoodTags(
                  location: location,
                  startTime: widget.holder.startDeliveryTime.value,
                  endTime: widget.holder.endDeliveryTime.value)
              .then((list) {
            deliveredNearbyFoodTags.value = list;
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorHelper.dabaoOffWhiteF5,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: Container(
                        padding: EdgeInsets.only(top: 18.0, bottom: 18.0),
                        child: Text(
                          "What are you having today?",
                          style: FontHelper.semiBold(
                              ColorHelper.dabaoOffBlack4A, 15.0),
                        ))),
                buildBeingDelivered(),
                buildReccomended(),
                buildUser(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void callback(selected) {
    if (selected is FoodTag) {
      FoodTag selectedFoodTag = selected;
      widget.holder.foodTag.value = selectedFoodTag.title.value;
      widget.nextPage();
    }
  }

  Column buildReccomended() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            "Reccomended",
            style: FontHelper.medium(ColorHelper.dabaoOffBlack4A, 12.0),
          ),
          padding: EdgeInsets.only(bottom: 5.0),
        ),
        GestureDetector(
          onTap: () {
            moveToSearch(context);
          },
          child: Container(
            margin: EdgeInsets.only(top: 5.0, bottom: 8.0, right: 25.0),
            height: 30.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: ColorHelper.dabaoOffGrey70)),
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/icons/search_icon.png',
                    color: ColorHelper.dabaoOffBlack9B,
                  ),
                  width: 18,
                  margin: EdgeInsets.only(left: 8.0, right: 8.0),
                ),
                Container(
                    child: Text(
                  "Search e.g Macdonalds, GongCha",
                  style: FontHelper.regular(ColorHelper.dabaoOffBlack9B, 12.0),
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            ),
          ),
        ),
        StreamBuilder(
          stream: reccomendedFoodTags.producer,
          builder: (context, snap) {
            if (snap.hasData) {
              return TagWrap(
                selectedCallBack: callback,
                taggables: reccomendedFoodTags,
              );
            } else {
              return Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }

  moveToSearch(BuildContext context) => Navigator.push(context,
          new PageRouteBuilder(pageBuilder: (BuildContext context, _, __) {
        return new FoodTypeSearch(
          selectedCallback: (String tag) {
            widget.holder.foodTag.value = tag;
            widget.nextPage();
          },
        );
      }));

  StreamBuilder<List<FoodTag>> buildBeingDelivered() {
    return StreamBuilder<List<FoodTag>>(
      stream: deliveredNearbyFoodTags.producer,
      builder: (context, snap) {
        if (!snap.hasData)
          return Align(
              alignment: Alignment.center, child: CircularProgressIndicator());

        if (snap.data.length == 0) return Container();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Being delivered near you",
                style: FontHelper.medium(ColorHelper.dabaoOffBlack4A, 12.0),
              ),
              padding: EdgeInsets.only(bottom: 5.0),
            ),
            TagWrap(
              selectedCallBack: callback,
              taggables: deliveredNearbyFoodTags,
            ),
            Line(
              margin: EdgeInsets.only(
                  right: 10.0, top: 10.0, bottom: 15.0, left: 10.0),
            )
          ],
        );
      },
    );
  }

  StreamBuilder<List<FoodTag>> buildUser() {
    return StreamBuilder<List<FoodTag>>(
      stream: userFoodTags.producer,
      builder: (context, snap) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Line(
              margin: EdgeInsets.only(
                  right: 10.0, top: 10.0, bottom: 15.0, left: 10.0),
            ),
            Container(
              child: Text(
                "Your custom orders",
                style: FontHelper.medium(ColorHelper.dabaoOffBlack4A, 12.0),
              ),
              padding: EdgeInsets.only(bottom: 5.0),
            ),
            TagWrap(
              selectedCallBack: callback,
              taggables: userFoodTags,
            ),
            Container(
              margin: EdgeInsets.only(right: 20.0),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: InputChip(
                    pressElevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(
                            color: ColorHelper.dabaoOrange,
                            style: BorderStyle.solid)),
                    backgroundColor: ColorHelper.dabaoOrange,
                    label: Image.asset(
                      'assets/icons/plus_icon.png',
                    ),
                    onPressed: () {
                      moveToSearch(context);
                    },
                  )),
            )
          ],
        );
      },
    );
  }
}
