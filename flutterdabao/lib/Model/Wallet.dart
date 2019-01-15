import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
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

  MutableProperty<List<Transact>> _listOfTransactions;
  MutableProperty<List<Transact>> get listOfTransactions {
    if (_listOfTransactions == null) {
      _listOfTransactions = MutableProperty(List());
      _listOfTransactions.bindTo(FirebaseCollectionReactive<Transact>(
        Firestore.instance
            .collection(className)
            .document(this.uid)
            .collection("statements")
            .document(DateTimeHelper.convertDateTimeToWeek(DateTime.now()))
            .collection('transactions'),
      ).observable);
    }
    return _listOfTransactions;
  }

  MutableProperty<double> _totalAmountEarnedThisWeek;
  MutableProperty<double> get totalAmountEarnedThisWeek {
    if (_totalAmountEarnedThisWeek == null) {
      _totalAmountEarnedThisWeek = MutableProperty(0.0);
      _totalAmountEarnedThisWeek.bindTo(FirebaseCollectionReactive<Transact>(
              Firestore.instance
                  .collection(className)
                  .document(this.uid)
                  .collection("statements")
                  .document(
                      DateTimeHelper.convertDateTimeToWeek(DateTime.now()))
                  .collection('transactions'))
          .observable
          .map((data) {
        double sum = 0;
        data.removeWhere((test) => test.type.value == "WITHDRAWAL");
        data.forEach((f) {
          sum = sum + f.amount.value;
        });
        return sum;
      }));
    }
    return _totalAmountEarnedThisWeek;
  }

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

    ;
  }
}
