import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/rxdart.dart';

class DabaoerRewards extends FirebaseType {

  static final String startTimeKey = "ST";
  static final String endTimeKey = "ET";

  BehaviorSubject<DateTime> startDate;
  BehaviorSubject<DateTime> endDate;


  DabaoerRewards.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  @override
  void map(Map<String, dynamic> data) {

    if (data.containsKey(startTimeKey));

  }

  @override
  void setUpVariables() {

    endDate = BehaviorSubject();
    startDate = BehaviorSubject();


  }

}

class DabaoerRewardsMilestone extends FirebaseType{

    final String quantityOfComfirmedOrdersKey = "QTY";
  final String rewardAmountKey = "A";
  final String titleKey = "T";
  final String descriptionKey = "D";

  BehaviorSubject<int> quantityOfComfirmedOrders;
  BehaviorSubject<double> rewardAmount;
  BehaviorSubject<String> title;
  BehaviorSubject<String> description;

  DabaoerRewardsMilestone.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

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

    if (data.containsKey(rewardAmountKey)) {
      rewardAmount.add(data[rewardAmountKey] + 0.0);
    } else {
      rewardAmount.add(null);
    }  }

  @override
  void setUpVariables() {
    quantityOfComfirmedOrders = BehaviorSubject();
    title = BehaviorSubject();
    description = BehaviorSubject();
    rewardAmount = BehaviorSubject();  }
}
