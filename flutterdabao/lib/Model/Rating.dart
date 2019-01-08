import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/src/observables/observable.dart';
import 'package:rxdart/subjects.dart';

class Rating extends FirebaseType {
  static final String messageKey = "M";
  static final String createdDateKey = "createdDate";
  static final String ratingKey = "R";
  static final String reviewerKey = "RW";
  static final String orderIDKey = "orderID";

  BehaviorSubject<double> rating;
  BehaviorSubject<DateTime> createdDate;
  BehaviorSubject<String> message;
  BehaviorSubject<String> reviewer;
  BehaviorSubject<String> orderID;

  Rating.fromUID(String uid) : super.fromUID(uid);

  Rating.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  Rating.fromMap(String uid, Map<String, dynamic> data)
      : super.fromMap(uid, data);

  @override
  void map(Map<String, dynamic> map) {
    if (data.containsKey(ratingKey)) {
      rating.add(data[ratingKey] * 1.0);
    } else {
      rating.add(0.0);
    }

    if (data.containsKey(createdDateKey)) {
      Timestamp temp = data[createdDateKey];

      createdDate.add(temp.toDate());
    } else {
      createdDate.add(null);
    }

    if (data.containsKey(messageKey)) {
      message.add(data[messageKey]);
    } else {
      message.add(null);
    }

    if (data.containsKey(reviewerKey)) {
      reviewer.add(data[reviewerKey]);
    } else {
      reviewer.add(null);
    }

    if (data.containsKey(orderIDKey)) {
      orderID.add(data[orderIDKey]);
    } else {
      orderID.add(null);
    }
  }

  @override
  void setUpVariables() {
    createdDate = BehaviorSubject();
    orderID = BehaviorSubject();
    reviewer = BehaviorSubject();
    rating = BehaviorSubject();
    message = BehaviorSubject();

    
  }
}
