import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/Model/Message.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:rxdart/rxdart.dart';

class Channel extends FirebaseType with Selectable {
  static final String participantsKey = "P";
  static final String lastSentKey = "LS";
  static final String orderUidKey = "O";
  static final String delivererKey = "D";

  BehaviorSubject<List<String>> participantsID;
  BehaviorSubject<DateTime> lastSent;
  BehaviorSubject<String> orderUid;
  BehaviorSubject<int> unreadMessages;
  BehaviorSubject<String> deliverer;

  Observable<List<Message>> listOfMessages;
  Observable<List<Channel>> listOfChannel;

  Channel.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  Channel.fromUID(String uid) : super.fromUID(uid);

  @override
  void setUpVariables() {
    participantsID = BehaviorSubject();
    lastSent = BehaviorSubject();
    orderUid = BehaviorSubject();
    deliverer = BehaviorSubject();
    unreadMessages = BehaviorSubject();
    listOfMessages = FirebaseCollectionReactive<Message>(Firestore.instance
            .collection(className)
            .document(this.uid)
            .collection("messages")
            .orderBy('T', descending: true)
            .limit(100)).observable;
        

    // listOfChannel = FirebaseCollectionReactive<Channel>(Firestore.instance
    //         .collection(className)
    //         .where('P',
    //             arrayContains:
    //                 ConfigHelper.instance.currentUserProperty.value.uid)
    //         .limit(20))
    //     .observable;
  }

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(delivererKey)) {
      deliverer.add(data[delivererKey]);
    } else {
      deliverer.add(null);
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
}
