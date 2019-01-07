import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/Model/Transaction.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class Wallet extends FirebaseType {
  String currentValueKey = "CurrentValue";
  String inWithdrawalKey = "InWithdrawal";

  BehaviorSubject<double> currentValue;
  BehaviorSubject<double> inWithdrawal;

  Observable<List<Transact>> listOfTransactions;

  Wallet.fromUID(String uid) : super.fromUID(uid);

  @override
  void map(Map<String, dynamic> data) {
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

    listOfTransactions = FirebaseCollectionReactive<Transact>(Firestore.instance
            .collection(className)
            .document(this.uid)
            .collection("statements")
            .document('2019_WEEK_01')
            .collection('transactions')
            // .where('TYPE', isEqualTo: 'REWARD')
            ,)
        .observable;
  }
}
