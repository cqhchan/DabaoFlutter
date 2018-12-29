import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/rxdart.dart';

class Message extends FirebaseType with Selectable {
  static final String senderKey = "S";
  static final String timestampKey = "T";
  static final String messageKey = "M";
  static final String imageUrlKey = "I";

  BehaviorSubject<String> sender;
  BehaviorSubject<DateTime> timestamp;
  BehaviorSubject<GeoPoint> message;
  BehaviorSubject<String> imageUrl;


  Message.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  Message.fromUID(String uid) : super.fromUID(uid);

  @override
  void setUpVariables() {

    sender = BehaviorSubject();
    timestamp = BehaviorSubject();
    message = BehaviorSubject();
    imageUrl = BehaviorSubject();

  }

  @override
  void map(Map<String, dynamic> data) {

    if (data.containsKey(senderKey)) {
      sender.add(data[senderKey]);
    } else {
      sender.add(null);
    }

    if (data.containsKey(timestampKey)) {
      timestamp.add(data[timestampKey]);
    } else {
      timestamp.add(null);
    }

    if (data.containsKey(messageKey)) {
      message.add(data[messageKey]);
    } else {
      message.add(null);
    }

    if (data.containsKey(imageUrlKey)) {
      imageUrl.add(data[imageUrlKey]);
    } else {
      imageUrl.add(null);
    }
  }
}
