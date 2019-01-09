import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/Message.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:rxdart/rxdart.dart';

class Channel extends FirebaseType with Selectable {
  static final String participantsKey = "P";
  static final String lastSentKey = "LS";
  static final String orderUidKey = "O";
  static final String delivererKey = "D";
  static final String counterOfferKey = "CO";

  BehaviorSubject<List<String>> participantsID;
  BehaviorSubject<DateTime> lastSent;
  BehaviorSubject<String> orderUid;
  BehaviorSubject<int> unreadMessages;
  BehaviorSubject<String> deliverer;
  BehaviorSubject<CounterOffer> counterOffer;

  MutableProperty<List<Message>> _listOfMessages;

  MutableProperty<List<Message>> get listOfMessages {
    if (_listOfMessages == null) {
      _listOfMessages = MutableProperty(List());
      _listOfMessages.bindTo(FirebaseCollectionReactive<Message>(Firestore
              .instance
              .collection(className)
              .document(this.uid)
              .collection("messages")
              .orderBy('T', descending: true)
              .limit(100))
          .observable);
    }
    return _listOfMessages;
  }

  Channel.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  Channel.fromUID(String uid) : super.fromUID(uid);

  @override
  void setUpVariables() {
    participantsID = BehaviorSubject();
    lastSent = BehaviorSubject();
    orderUid = BehaviorSubject();
    deliverer = BehaviorSubject();
    unreadMessages = BehaviorSubject();
    counterOffer = BehaviorSubject();
  }

  void markAsRead() {
    if (ConfigHelper.instance.currentUserProperty.value != null)
      Firestore.instance
          .collection(this.className)
          .document(this.uid)
          .updateData({ConfigHelper.instance.currentUserProperty.value.uid: 0});
  }

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(delivererKey)) {
      deliverer.add(data[delivererKey]);
    } else {
      deliverer.add(null);
    }

    if (data.containsKey(counterOfferKey)) {
      Map<String, dynamic> offerData =
          Map.castFrom<dynamic, dynamic, String, dynamic>(
              data[counterOfferKey]);

      counterOffer.add(CounterOffer(offerData));
    } else {
      counterOffer.add(null);
    }

    if (data.containsKey(orderUidKey)) {
      orderUid.add(data[orderUidKey]);
    } else {
      orderUid.add(null);
    }

    // handle unread messages
    if (ConfigHelper.instance.currentUserProperty.value != null) {
      if (data
          .containsKey(ConfigHelper.instance.currentUserProperty.value.uid)) {
        unreadMessages
            .add(data[ConfigHelper.instance.currentUserProperty.value.uid]);
      } else {
        unreadMessages.add(0);
      }
    }

    if (data.containsKey(participantsKey)) {
      List<String> userId =
          List.castFrom<dynamic, String>(data[participantsKey]);
      participantsID.add(userId);
    } else {
      participantsID.add(null);
    }

    if (data.containsKey(lastSentKey)) {
      Timestamp timestamp = data[lastSentKey];
      lastSent.add(timestamp.toDate());
    } else {
      lastSent.add(null);
    }
  }

  addMessage(String message, String sender, String image) {
    Firestore.instance
        .collection(className)
        .document(this.uid)
        .collection('messages')
        .add({
      "I": image,
      "M": message,
      "S": sender,
      "T": DateTime.now(),
    });
  }

  setCounterOffer(double price, DateTime deliveryTime, String offererID) {
    Map data = Map();
    data[CounterOffer.priceKey] = price;
    data[CounterOffer.deliveryTimeKey] = deliveryTime;
    data[CounterOffer.statusKey] = CounterOffer.counterOffStatus_Open;
    data[CounterOffer.offererIDKey] = offererID;

    Firestore.instance
        .collection(className)
        .document(this.uid)
        .updateData({counterOfferKey: data});
  }

  reject() {
    Map data = Map();

    data[CounterOffer.statusKey] = CounterOffer.counterOffStatus_Rejected;

    Firestore.instance
        .collection(className)
        .document(this.uid)
        .updateData({counterOfferKey: data});
  }

    accept() {
    Map data = Map();

    data[CounterOffer.statusKey] = CounterOffer.counterOffStatus_Accepted;

    Firestore.instance
        .collection(className)
        .document(this.uid)
        .updateData({counterOfferKey: data});
  }
}

class CounterOffer {
  static String counterOffStatus_Open = "Open";
  static String counterOffStatus_Accepted = "Accepted";
  static String counterOffStatus_Rejected = "Rejected";

  static String priceKey = "P";
  static String deliveryTimeKey = "DT";
  static String statusKey = "S";
  static String offererIDKey = "O";

  double price;
  DateTime deliveryTime;
  String offererID;
  String status;

  CounterOffer(Map<String, dynamic> offerData) {
    if (offerData.containsKey(priceKey)) price = offerData[priceKey] + 0.0;

    if (offerData.containsKey(deliveryTimeKey)) {
      Timestamp timestamp = offerData[deliveryTimeKey];
      deliveryTime = (timestamp.toDate());
    }

    if (offerData.containsKey(statusKey)) {
      status = offerData[statusKey];
    }

    if (offerData.containsKey(offererIDKey)) {
      offererIDKey = offerData[offererIDKey];
    }
  }
}
