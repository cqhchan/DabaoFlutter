import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/subjects.dart';

class Transact extends FirebaseType {
  static final String amountKey = "Amount";
  static final String createDateKey = "CreatedDate";
  static final String typeKey = "TYPE";
  static final String rewardPathKey = "rewardPath";
  static final String rewardTitleKey = "rewardTitle";

  BehaviorSubject<int> amount;
  BehaviorSubject<DateTime> createDate;
  BehaviorSubject<String> type;
  BehaviorSubject<String> rewardPath;
  BehaviorSubject<String> rewardTitle;

  Transact.fromDocument(DocumentSnapshot doc)
      : super.fromDocument(doc);

  Transact.fromMap(String uid, Map<String, dynamic> data)
      : super.fromMap(uid, data);

  @override
  void map(Map<String, dynamic> map) {
    if (map.containsKey(amountKey)) {
      amount.add(map[amountKey]);
    } else {
      amount.add(0);
    }

    if (map.containsKey(createDateKey)) {
      createDate.add(map[createDateKey]);
    } else {
      createDate.add(null);
    }

    if (map.containsKey(typeKey)) {
      type.add(map[typeKey]);
    } else {
      type.add(null);
    }

    if (map.containsKey(rewardPathKey)) {
      rewardPath.add(map[rewardPathKey]);
    } else {
      rewardPath.add(null);
    }

    if (map.containsKey(rewardTitleKey)) {
      rewardTitle.add(map[rewardTitleKey]);
    } else {
      rewardTitle.add(null);
    }
  }

  @override
  void setUpVariables() {
    amount = BehaviorSubject();
    createDate = BehaviorSubject();
    type = BehaviorSubject();
    rewardPath = BehaviorSubject();
    rewardTitle = BehaviorSubject();
  }
}
