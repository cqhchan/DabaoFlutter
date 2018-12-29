import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/Model/Message.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:rxdart/rxdart.dart';

class Channel extends FirebaseType with Selectable {
  static final String participantsKey = "P";
  static final String lastSentKey = "LS";
  static final String orderUidKey = "O";

  BehaviorSubject<List<String>> participantsID;
  BehaviorSubject<DateTime> lastSent;
  Observable<List<Message>> listOfMessages;
  BehaviorSubject<String> orderUid;

  Channel.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  Channel.fromUID(String uid) : super.fromUID(uid);

  @override
  void setUpVariables() {
    participantsID = BehaviorSubject();
    lastSent = BehaviorSubject();
    orderUid = BehaviorSubject();

    listOfMessages = FirebaseCollectionReactive<Message>(Firestore.instance
            .collection("channels")
            .document(this.uid)
            .collection("messages"))
        .observable;
  }

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(orderUidKey)) {
      orderUid.add(data[orderUidKey]);
    } else {
      orderUid.add(null);
    }

    if (data.containsKey(participantsKey)) {
      List<String> userId =
          List.castFrom<dynamic, String>(data[participantsKey]);
      participantsID.add(userId);
    } else {
      participantsID.add(null);
    }

    if (data.containsKey(lastSentKey)) {
      lastSent
          .add(DateTimeHelper.convertStringTimeToDateTime(data[lastSentKey]));
    } else {
      lastSent.add(null);
    }
  }

  addMessage(String message, String sender) {
    Firestore.instance
        .collection(className)
        .document(this.uid)
        .collection('messages')
        .add({
      "M": message,
      "S": sender,
      "T": DateTimeHelper.convertDateTimeToString(DateTime.now()),
    });
  }
}
