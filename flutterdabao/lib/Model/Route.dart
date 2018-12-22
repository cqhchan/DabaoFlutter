import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/RouteHolder.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:rxdart/subjects.dart';

class Route extends FirebaseType {
  static final String creatorKey = "C";
  static final String createdTimeKey = "CT";

  static final String deliveryLocationKey = "DL";
  static final String deliveryLocationDescriptionKey = "LD";
  static final String deliveryTimeKey = "DT";

  static final String startLocationKey = "SL";
  static final String startLocationDescriptionKey = "SLD";
  static final String foodTagKey = "FT";

  BehaviorSubject<GeoPoint> startLocation;
  BehaviorSubject<String> startLocationDescription;
  BehaviorSubject<GeoPoint> deliveryLocation;
  BehaviorSubject<String> deliveryLocationDescription;
  BehaviorSubject<DateTime> deliveryTime;
  BehaviorSubject<String> creator;
  BehaviorSubject<List<String>> foodTags;

  MutableProperty<List<Order>> listOfOrdersAccepted;

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
      deliveryLocation.add(data[deliveryLocationKey]);
    } else {
      deliveryLocation.add(null);
    }

    if (data.containsKey(deliveryLocationDescription)) {
      deliveryLocationDescription.add(data[deliveryLocationDescription]);
    } else {
      deliveryLocationDescription.add(null);
    }

    if (data.containsKey(deliveryLocationKey)) {
      startLocation.add(data[deliveryLocationKey]);
    } else {
      startLocation.add(null);
    }

    if (data.containsKey(deliveryLocationDescription)) {
      startLocationDescription.add(data[deliveryLocationDescription]);
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
      foodTags.add(data[foodTagKey]);
    }
    foodTags.add(data[List()]);
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

    listOfOrdersAccepted.bindTo(FirebaseCollectionReactive(Firestore.instance
            .collection("orders")
            .where('route', isEqualTo: this.uid))
        .observable);
  }

  static isValid(RouteHolder holder) {
    if (holder.startDeliveryLocation.value == null) return false;

    if (holder.startDeliveryLocationDescription.value == null) return false;

    if (holder.endDeliveryLocation.value == null) return false;

    if (holder.endDeliveryLocationDescription.value == null) return false;

    if (holder.deliveryTime.value == null) return false;

    return true;
  }

  static Future<bool> createRoute(RouteHolder holder) async {
    Map<String, dynamic> data = Map();
    data[createdTimeKey] =
        DateTimeHelper.convertDateTimeToString(DateTime.now());

    data[deliveryLocationKey] = {
      "lat": holder.endDeliveryLocation.value.latitude,
      "long": holder.endDeliveryLocation.value.longitude
    };

    data[startLocationKey] = {
      "lat": holder.startDeliveryLocation.value.latitude,
      "long": holder.startDeliveryLocation.value.longitude
    };

    data[deliveryLocationDescriptionKey] =
        holder.endDeliveryLocationDescription.value;

    data[startLocationDescriptionKey] =
        holder.startDeliveryLocationDescription.value;

    data[foodTagKey] = holder.foodTags.value;

    data[creatorKey] = ConfigHelper.instance.currentUserProperty.value.uid;

    data[deliveryTimeKey] =
        DateTimeHelper.convertDateTimeToString(holder.deliveryTime.value);


    
  }
}
