import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/rxdart.dart';

class DabaoeeReward extends FirebaseType {
  static final String startTimeKey = "ST";
  static final String endTimeKey = "ET";
  static final String validKey = "V";

  BehaviorSubject<DateTime> startDate;
  BehaviorSubject<DateTime> endDate;

  Observable<List<DabaoeeRewardsMilestone>> milestones;

  DabaoeeReward.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(startTimeKey)) {
      Timestamp temp = data[startTimeKey];
      startDate.add(temp.toDate());
    } else {
      startDate.add(null);
    }

    if (data.containsKey(endTimeKey)) {
      Timestamp temp = data[endTimeKey];
      endDate.add(temp.toDate());
    } else {
      endDate.add(null);
    }
  }

  @override
  void setUpVariables() {
    endDate = BehaviorSubject();
    startDate = BehaviorSubject();
    milestones = FirebaseCollectionReactive<DabaoeeRewardsMilestone>(Firestore
            .instance
            .collection(this.className)
            .document(this.uid)
            .collection("dabaoeeRewardsMilestones"))
        .observable;
  }
}

class DabaoeeRewardsMilestone extends FirebaseType {
  final String quantityOfComfirmedOrdersKey = "QTY";
  final String titleKey = "T";
  final String descriptionKey = "D";
  final String voucherKey = "V";
  final String voucherDescriptionKey = "VD";

  BehaviorSubject<int> quantityOfComfirmedOrders;
  BehaviorSubject<String> title;
  BehaviorSubject<String> description;
  BehaviorSubject<String> voucher;
  BehaviorSubject<String> voucherDescription;

  DabaoeeRewardsMilestone.fromDocument(DocumentSnapshot doc)
      : super.fromDocument(doc);

  @override
  void map(Map<String, dynamic> data) {
    
    if (data.containsKey(quantityOfComfirmedOrdersKey)) {
      quantityOfComfirmedOrders.add(data[quantityOfComfirmedOrdersKey]);
    } else {
      quantityOfComfirmedOrders.add(null);
    }

    if (data.containsKey(titleKey)) {
      title.add(data[titleKey]);
    } else {
      title.add(null);
    }

    if (data.containsKey(descriptionKey)) {
      description.add(data[descriptionKey]);
    } else {
      description.add(null);
    }

    if (data.containsKey(voucherKey)) {
      voucher.add(data[voucherKey]);
    } else {
      voucher.add(null);
    }

    if (data.containsKey(voucherDescriptionKey)) {
      voucherDescription.add(data[voucherDescriptionKey]);
    } else {
      voucherDescription.add(null);
    }
  }

  @override
  void setUpVariables() {
    quantityOfComfirmedOrders = BehaviorSubject();
    title = BehaviorSubject();
    description = BehaviorSubject();
    voucher = BehaviorSubject();
    voucherDescription = BehaviorSubject();
  }
}
