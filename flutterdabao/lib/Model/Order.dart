import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:rxdart/rxdart.dart';

final String orderStatus_Requested = "Requested";
final String orderStatus_Accepted = "Accepted";

class Order extends FirebaseType with Selectable {
  static final String createdTimeKey = "CT";
  static final String startTimeKey = "ST";
  static final String endTimeKey = "ET";
  static final String deliveryTimeKey = "DT";
  static final String deliveryLocationKey = "L";
  static final String deliveryLocationDescriptionKey = "LD";
  static final String foodTagKey = "FT";
  static final String orderItemKey = "OI";
  static final String creatorKey = "C";
  static final String deliveryFeeKey = "DF";
  static final String modeKey = "MD";
  static final String messageKey = "ME";
  static final String statusKey = "S";

  BehaviorSubject<DateTime> createdDeliveryTime;
  BehaviorSubject<DateTime> startDeliveryTime;
  BehaviorSubject<DateTime> endDeliveryTime;

  //Created when Dabaoer Accepts exact delivery timing
  BehaviorSubject<DateTime> deliveryTime;

  BehaviorSubject<GeoPoint> deliveryLocation;
  BehaviorSubject<String> deliveryLocationDescription;
  BehaviorSubject<String> foodTag;
  BehaviorSubject<List<OrderItem>> orderItems;
  BehaviorSubject<String> creator;
  BehaviorSubject<String> message;
  BehaviorSubject<OrderMode> mode;
  BehaviorSubject<double> deliveryFee;

  Order.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  Order.fromUID(String uid) : super.fromUID(uid);

  Order.fromMap(String uid, Map<String, dynamic> data)
      : super.fromMap(uid, data);

  @override
  void setUpVariables() {
    deliveryTime = BehaviorSubject();
    createdDeliveryTime = BehaviorSubject();
    startDeliveryTime = BehaviorSubject();
    endDeliveryTime = BehaviorSubject();
    deliveryLocation = BehaviorSubject();
    deliveryLocationDescription = BehaviorSubject();
    foodTag = BehaviorSubject();
    orderItems = BehaviorSubject();
    creator = BehaviorSubject();
    deliveryFee = BehaviorSubject();
    mode = BehaviorSubject();
    message = BehaviorSubject();
  }

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(createdTimeKey)) {
      createdDeliveryTime.add(
          DateTimeHelper.convertStringTimeToDateTime(data[createdTimeKey]));
    } else {
      createdDeliveryTime.add(null);
    }

    if (data.containsKey(startTimeKey)) {
      startDeliveryTime
          .add(DateTimeHelper.convertStringTimeToDateTime(data[startTimeKey]));
    } else {
      startDeliveryTime.add(null);
    }

    if (data.containsKey(deliveryTimeKey)) {
      deliveryTime.add(
          DateTimeHelper.convertStringTimeToDateTime(data[deliveryTimeKey]));
    } else {
      deliveryTime.add(null);
    }

    if (data.containsKey(modeKey)) {
      switch (data[modeKey]) {
        case "ASAP":
          mode.add(OrderMode.asap);
          break;

        case "SCHEDULED":
          mode.add(OrderMode.scheduled);

          break;
      }
    } else {
      mode.add(null);
    }

    if (data.containsKey(endTimeKey)) {
      endDeliveryTime
          .add(DateTimeHelper.convertStringTimeToDateTime(data[endTimeKey]));
    } else {
      endDeliveryTime.add(null);
    }

    if (data.containsKey(deliveryLocationKey)) {
      deliveryLocation.add(data[deliveryLocationKey]);
    } else {
      deliveryLocation.add(null);
    }

    if (data.containsKey(deliveryLocationDescriptionKey)) {
      deliveryLocationDescription.add(data[deliveryLocationDescriptionKey]);
    } else {
      deliveryLocationDescription.add(null);
    }

    if (data.containsKey(deliveryFeeKey)) {
      deliveryFee.add(data[deliveryFeeKey] + 0.0);
    } else {
      deliveryFee.add(null);
    }

    if (data.containsKey(messageKey)) {
      message.add(data[messageKey]);
    } else {
      message.add(null);
    }

    if (data.containsKey(orderItemKey)) {

      List<Map<dynamic, dynamic>> temp =  List.castFrom<dynamic,Map<dynamic, dynamic>>( data[orderItemKey]);

      orderItems.add(temp.map((rawMap) {
        var map = rawMap.cast<String, dynamic>();
        return OrderItem.fromMap(
            map[OrderItem.titleKey].toString().toLowerCase(), map);
      }).toList());
    } else {
      orderItems.add(List());
    }

    if (data.containsKey(creatorKey)) {
      creator.add(data[creatorKey]);
    } else {
      creator.add(null);
    }

    if (data.containsKey(foodTagKey)) {
      foodTag.add(data[foodTagKey]);
    } else {
      foodTag.add(null);
    }
  }

  static bool isValid(OrderHolder holder) {
    if (holder.foodTag.value == null) return false;

    if (holder.deliveryFee.value == null) return false;

    if (holder.deliveryLocation.value == null) return false;

    if (holder.deliveryLocationDescription.value == null) return false;

    if (holder.orderItems.value == null) return false;

    if (holder.orderItems.value.length == 0) return false;


    if (holder.mode.value == null) return false;

    switch (holder.mode.value) {
      case OrderMode.asap:
        break;

      case OrderMode.scheduled:
        if (holder.startDeliveryTime.value == null) return false;
        if (holder.endDeliveryTime.value == null) return false;
        break;
    }

    return true;
  }

  static Future<bool> createOrder(OrderHolder holder) async {
    Map<String, dynamic> data = Map();

    data[createdTimeKey] =
        DateTimeHelper.convertDateTimeToString(DateTime.now());

    data[deliveryLocationKey] = {
      "lat": holder.deliveryLocation.value.latitude,
      "long": holder.deliveryLocation.value.longitude
    };

    data[deliveryLocationDescriptionKey] =
        holder.deliveryLocationDescription.value;

    data[foodTagKey] = holder.foodTag.value;

    data[deliveryFeeKey] = holder.deliveryFee.value;

    data[messageKey] = holder.message.value;

    data[creatorKey] = ConfigHelper.instance.currentUserProperty.value.uid;

    data[orderItemKey] = holder.orderItems.value.map((item) {
      return item.toMap();
    }).toList();

    switch (holder.mode.value) {
      case OrderMode.asap:
        data[modeKey] = "ASAP";
        data[startTimeKey] =
            DateTimeHelper.convertDateTimeToString(DateTime.now());
        if (holder.cutOffDeliveryTime.value != null) {
          data[endTimeKey] = DateTimeHelper.convertDateTimeToString(
              holder.cutOffDeliveryTime.value);
        }
        break;

      case OrderMode.scheduled:
        data[modeKey] = "SCHEDULED";
        data[startTimeKey] = DateTimeHelper.convertDateTimeToString(
            holder.startDeliveryTime.value);
        data[endTimeKey] = DateTimeHelper.convertDateTimeToString(
            holder.endDeliveryTime.value);

        break;
    }

    return FirebaseCloudFunctions.createOrder(data: data);
  }
}
