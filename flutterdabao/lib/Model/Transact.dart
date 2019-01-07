import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/subjects.dart';

class Transact extends FirebaseType {
  static final String amountKey = "Amount";
  static final String createdDateKey = "CreatedDate";
  static final String typeKey = "TYPE";
  static final String rewardPathKey = "rewardPath";
  static final String rewardTitleKey = "rewardTitle";

  static final String statementIDKey = "statementID";
  static final String orderIDKey = "orderID";
  static final String walletIDKey = "walletID";

  BehaviorSubject<int> amount;
  BehaviorSubject<DateTime> createdDate;
  BehaviorSubject<String> type;
  BehaviorSubject<String> rewardPath;
  BehaviorSubject<String> rewardTitle;

  BehaviorSubject<String> statementID;
  BehaviorSubject<String> orderID;
  BehaviorSubject<String> walletID;

  Transact.fromUID(String uid) : super.fromUID(uid);

  Transact.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  Transact.fromMap(String uid, Map<String, dynamic> data)
      : super.fromMap(uid, data);

  @override
  void map(Map<String, dynamic> map) {
    if (data.containsKey(amountKey)) {
      amount.add(data[amountKey]);
    } else {
      amount.add(0);
    }

    if (data.containsKey(createdDateKey)) {
      Timestamp temp = data[createdDateKey];

      createdDate.add(temp.toDate());
    } else {
      createdDate.add(null);
    }

    if (data.containsKey(typeKey)) {
      type.add(data[typeKey]);
    } else {
      type.add(null);
    }

    if (data.containsKey(rewardPathKey)) {
      rewardPath.add(data[rewardPathKey]);
    } else {
      rewardPath.add(null);
    }

    if (data.containsKey(rewardTitleKey)) {
      rewardTitle.add(data[rewardTitleKey]);
    } else {
      rewardTitle.add(null);
    }

    if (data.containsKey(statementIDKey)) {
      statementID.add(data[statementIDKey]);
    } else {
      statementID.add(null);
    }

    if (data.containsKey(orderIDKey)) {
      orderID.add(data[orderIDKey]);
    } else {
      orderID.add(null);
    }

    if (data.containsKey(walletIDKey)) {
      walletID.add(data[walletIDKey]);
    } else {
      walletID.add(null);
    }
  }

  @override
  void setUpVariables() {
    amount = BehaviorSubject();
    createdDate = BehaviorSubject();
    type = BehaviorSubject();
    rewardPath = BehaviorSubject();
    rewardTitle = BehaviorSubject();
    statementID = BehaviorSubject();
    orderID = BehaviorSubject();
    walletID = BehaviorSubject();
  }
}
