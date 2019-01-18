import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:rxdart/subjects.dart';

// These status are for user USER
String voucher_Status_Open = "Open"; 
String voucher_Status_InUsed = "InUsed";
String voucher_Status_Used = "Used";

// These Satus are for Global;
String voucher_Status_Public = "Public"; 
String voucher_Status_Private = "Private";

String voucher_Type_Redemption = "REDEMPTION"; 
String voucher_Type_Discount = "DISCOUNT";

class Voucher extends FirebaseType {
  static final String expiryTimeKey = "ET";
  static final String titleKey = "T";
  static final String descriptionKey = "D";
  static final String foodTagKey = "FT";
  static final String deliveryFeeDiscountKey = "DFD";
  static final String codeKey = "C";
  static final String statusKey = "S";

  static final String typeKey = "TY";

  BehaviorSubject<String> code;
  BehaviorSubject<String> title;
  BehaviorSubject<String> description;
  BehaviorSubject<String> foodTag;
  BehaviorSubject<String> status;
  BehaviorSubject<String> type;

  BehaviorSubject<double> deliveryFeeDiscount;
  BehaviorSubject<DateTime> expiryDate;

  Voucher.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);
  Voucher.fromUID(String uid) : super.fromUID(uid);

  @override
  void map(Map<String, dynamic> data) {

    if (data.containsKey(expiryTimeKey)) {
      Timestamp temp = data[expiryTimeKey];
      expiryDate
          .add(temp.toDate());
    } else {
      expiryDate.add(null);
    }

    if (data.containsKey(codeKey)) {
      code.add(data[codeKey]);
    } else {
      code.add(null);
    }

    if (data.containsKey(typeKey)) {
      type.add(data[typeKey]);
    } else {
      type.add(null);
    }

    if (data.containsKey(statusKey)) {
      status.add(data[statusKey]);
    } else {
      status.add(null);
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

    if (data.containsKey(foodTagKey)) {
      foodTag.add(data[foodTagKey]);
    } else {
      foodTag.add(null);
    }

    if (data.containsKey(deliveryFeeDiscountKey)) {
      deliveryFeeDiscount.add(data[deliveryFeeDiscountKey] + 0.0);
    } else {
      deliveryFeeDiscount.add(null);
    }

  }

  @override
  void setUpVariables() {
    code = BehaviorSubject();
    title = BehaviorSubject();
    description = BehaviorSubject();
    foodTag = BehaviorSubject();
    deliveryFeeDiscount = BehaviorSubject();
    expiryDate = BehaviorSubject();
    status = BehaviorSubject();
    type = BehaviorSubject();
  }
}
