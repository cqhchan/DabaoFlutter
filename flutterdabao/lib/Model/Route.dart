import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Holder/RouteHolder.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

final String routeStatus_Open = "Open";

class Route extends FirebaseType {
  static final String creatorKey = "C";
  static final String statusKey = "S";
  static final String createdTimeKey = "CT";

  static final String deliveryLocationKey = "DL";
  static final String deliveryLocationDescriptionKey = "LD";
  static final String deliveryTimeKey = "DT";

  static final String startLocationKey = "SL";
  static final String startLocationDescriptionKey = "SLD";
  static final String foodTagKey = "FT";

  BehaviorSubject<GeoPoint> startLocation;
  BehaviorSubject<String> startLocationDescription;
  BehaviorSubject<List<GeoPoint>> deliveryLocation;
  BehaviorSubject<List<String>> deliveryLocationDescription;
  BehaviorSubject<DateTime> deliveryTime;
  BehaviorSubject<String> creator;
  BehaviorSubject<List<String>> foodTags;

  MutableProperty<List<Order>> listOfOrdersAccepted = MutableProperty(List<Order>());
  Observable<List<Order>> listOfPotentialOrders;


  Route.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);
  Route.fromUID(String uid) : super.fromUID(uid);

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(creatorKey)) {
      creator.add(data[creatorKey]);
    } else {
      creator.add(null);
    }

    if (data.containsKey(deliveryLocationKey)) {
      List<GeoPoint> temp = List.castFrom<dynamic,GeoPoint>((data[deliveryLocationKey]));
      deliveryLocation.add(temp);
    } else {
      deliveryLocation.add(null);
    }

    if (data.containsKey(deliveryLocationDescriptionKey)) {
      List<String> temp = List.castFrom<dynamic,String>((data[deliveryLocationDescriptionKey]));
      deliveryLocationDescription.add(temp);
    } else {
      deliveryLocationDescription.add(null);
    }    


    if (data.containsKey(startLocationKey)) {
      startLocation.add(data[startLocationKey]);
    } else {
      startLocation.add(null);
    }

    if (data.containsKey(startLocationDescriptionKey)) {
      startLocationDescription.add(data[startLocationDescriptionKey]);
    } else {
      startLocationDescription.add(null);
    }

    if (data.containsKey(deliveryTimeKey)) {
      deliveryTime.add(
          DateTimeHelper.convertStringTimeToDateTime(data[deliveryTimeKey]));
    } else {
      deliveryTime.add(null);
    }

    if (data.containsKey(foodTagKey)) {
      List<String> temp = List.castFrom<dynamic,String>((data[foodTagKey]));
      foodTags.add(temp);
    } else {
    foodTags.add(data[List()]);
    }

  }

  @override
  void setUpVariables() {
    foodTags = BehaviorSubject();
    creator = BehaviorSubject();
    deliveryTime = BehaviorSubject();
    startLocation = BehaviorSubject();
    startLocationDescription = BehaviorSubject();
    deliveryLocation = BehaviorSubject();
    deliveryLocationDescription = BehaviorSubject();

    listOfPotentialOrders = FirebaseCollectionReactive<Order>(Firestore.instance
            .collection("orders")
            .where(Order.statusKey, isEqualTo: orderStatus_Requested)
            .where(Order.potentialDeliveryKey, arrayContains: this.uid))
        .observable;

    listOfOrdersAccepted.bindTo(FirebaseCollectionReactive<Order>(Firestore.instance
            .collection("orders")
            .where(Order.routeKey, isEqualTo: this.uid))
        .observable);
  }

  static bool isValid(RouteHolder holder) {
    if (holder.startDeliveryLocation.value == null) return false;

    if (holder.startDeliveryLocationDescription.value == null) return false;

    if (holder.endDeliveryLocation.value == null) return false;

    if (holder.endDeliveryLocationDescription.value == null) return false;

    if (holder.deliveryTime.value == null) return false;

    if (holder.foodTags.value == null) return false;

    if (holder.foodTags.value.length == 0) return false;

    return true;
  }

  static Future<bool> createRoute(RouteHolder holder) async {
    Map<String, dynamic> data = Map();
    data[createdTimeKey] =
        DateTimeHelper.convertDateTimeToString(DateTime.now());

    data[startLocationKey] = {
      "lat": holder.startDeliveryLocation.value.latitude,
      "long": holder.startDeliveryLocation.value.longitude
    };

    List<Map> listOfDeliveryLoction = List();

    listOfDeliveryLoction.add({
      "lat": holder.endDeliveryLocation.value.latitude,
      "long": holder.endDeliveryLocation.value.longitude
    });

    data[deliveryLocationKey] = listOfDeliveryLoction;

    List<String> listOfDeliveryLoctionDescription = List();

    listOfDeliveryLoctionDescription
        .add(holder.endDeliveryLocationDescription.value);
    data[deliveryLocationDescriptionKey] = listOfDeliveryLoctionDescription;

    data[startLocationDescriptionKey] =
        holder.startDeliveryLocationDescription.value;

    data[foodTagKey] = holder.foodTags.value;

    data[creatorKey] = ConfigHelper.instance.currentUserProperty.value.uid;

    data[deliveryTimeKey] =
        DateTimeHelper.convertDateTimeToString(holder.deliveryTime.value);

    return FirebaseCloudFunctions.createRoute(data: data);
  }
}
