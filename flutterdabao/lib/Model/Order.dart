import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:rxdart/rxdart.dart';

class Order extends FirebaseType with Selectable {
  static final String createdDeliveryTimeKey = "CT";
  static final String startDeliveryTimeKey = "ST";
  static final String endDeliveryTimeKey = "ET";
  static final String deliveryLocationKey = "L";
  static final String deliveryLocationDescriptionKey = "LD";
  static final String foodTagKey = "FT";
  static final String orderItemKey = "OI";
  static final String creatorKey = "C";
  static final String deliveryFeeKey = "DF";
  static final String modeKey = "MD";
  static final String messageKey = "ME";

  BehaviorSubject<String> createdDeliveryTime;
  BehaviorSubject<String> startDeliveryTime;
  BehaviorSubject<String> endDeliveryTime;
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
    if (data.containsKey(createdDeliveryTimeKey)) {
      createdDeliveryTime.add(data[createdDeliveryTimeKey]);
    } else {
      createdDeliveryTime.add(null);
    }

    if (data.containsKey(startDeliveryTimeKey)) {
      startDeliveryTime.add(data[startDeliveryTimeKey]);
    } else {
      startDeliveryTime.add(null);
    }

    if (data.containsKey(modeKey)) {
      switch (data[modeKey]) {
        case "ASAP":
          mode.add(OrderMode.asap);
          break;

        case "SCHEDULED":
          mode.add(OrderMode.scheduled);

          if (data.containsKey(endDeliveryTimeKey)) {
            endDeliveryTime.add(data[endDeliveryTimeKey]);
          } else {
            endDeliveryTime.add(null);
          }
          break;
      }
    } else {
      mode.add(null);
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

    if (data.containsKey(deliveryFeeKey)) {
      deliveryFee.add(data[deliveryFeeKey]);
    } else {
      deliveryFee.add(null);
    }

    if (data.containsKey(messageKey)) {
      message.add(data[messageKey]);
    } else {
      message.add(null);
    }
// orderItems
    // if (data.containsKey(titleKey)) {
    //   title.add(data[titleKey]);
    // } else {
    //   title.add(null);
    // }

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
    if (holder.startDeliveryTime.value == null) return false;

    if (holder.foodTag.value == null) return false;

    if (holder.deliveryFee.value == null) return false;

    if (holder.deliveryLocation.value == null) return false;

    if (holder.deliveryLocationDescription.value == null) return false;

    if (holder.orderItems.value == null) return false;

    if (holder.orderItems.value.length == 0) return false;

    //Optional
    // if (holder.message.value == null) return false;
    // print("testing 9");

    if (holder.mode.value == null) return false;

    switch (holder.mode.value) {
      case OrderMode.asap:
        break;

      case OrderMode.scheduled:

        if (holder.endDeliveryTime.value == null) return false;
        break;
    }

    return true;
  }

  static void createOrder(OrderHolder holder) {
    Map<String, dynamic> data = Map();

    data[createdDeliveryTimeKey] =
        DateTimeHelper.convertDateTimeToString(DateTime.now());

    data[startDeliveryTimeKey] =
        DateTimeHelper.convertDateTimeToString(holder.startDeliveryTime.value);

    data[deliveryLocationKey] = GeoPoint(holder.deliveryLocation.value.latitude,
        holder.deliveryLocation.value.longitude);

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

        break;

      case OrderMode.scheduled:
        data[modeKey] = "SCHEDULED";
        data[endDeliveryTimeKey] = DateTimeHelper.convertDateTimeToString(
            holder.endDeliveryTime.value);

        break;
    }

    Firestore.instance.collection("orders").add(data);
  }
}
