import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/Model/Transact.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class Wallet extends FirebaseType {
  String currentValueKey = "CurrentValue";
  String inWithdrawalKey = "InWithdrawal";
  String createdDateKey = "CreatedDate";

  BehaviorSubject<DateTime> createdDate;
  BehaviorSubject<double> currentValue;
  BehaviorSubject<double> inWithdrawal;

  Observable<List<Transact>> listOfTransactions;
  Observable<double> totalAmountEarnedThisWeek;

  Wallet.fromUID(String uid) : super.fromUID(uid);

  Wallet.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(createdDateKey)) {
      Timestamp temp = data[createdDateKey];

      createdDate.add(temp.toDate());
    } else {
      createdDate.add(null);
    }

    if (data.containsKey(currentValueKey)) {
      currentValue.add(data[currentValueKey] + 0.0);
    } else {
      currentValue.add(null);
    }

    if (data.containsKey(inWithdrawalKey)) {
      inWithdrawal.add(data[inWithdrawalKey] + 0.0);
    } else {
      inWithdrawal.add(null);
    }
  }

  @override
  void setUpVariables() {
    currentValue = BehaviorSubject();
    inWithdrawal = BehaviorSubject();
    createdDate = BehaviorSubject();
    listOfTransactions = FirebaseCollectionReactive<Transact>(
      Firestore.instance
          .collection(className)
          .document(this.uid)
          .collection("statements")
          .document(DateTimeHelper.convertDateTimeToWeek(DateTime.now()))
          .collection('transactions'),
    ).observable;

    totalAmountEarnedThisWeek = FirebaseCollectionReactive<Transact>(Firestore
            .instance
            .collection(className)
            .document(this.uid)
            .collection("statements")
            .document(DateTimeHelper.convertDateTimeToWeek(DateTime.now()))
            .collection('transactions'))
        .observable
        .map((data) {
      double sum = 0;
      data.removeWhere((test) => test.type.value == "WITHDRAWAL");
      data.forEach((f) {
        sum = sum + f.amount.value;
      });
      return sum;
    });
  }
}
