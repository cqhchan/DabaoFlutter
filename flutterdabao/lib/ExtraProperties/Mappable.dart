import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/CustomError/FatalError.dart';
import 'package:flutterdabao/CustomWidget/Headers/Category.dart';
import 'package:flutterdabao/ExtraProperties/Identifiable.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Route.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Model/Voucher.dart';

// ALL MAPPABLE MUST DECLARE THEIR Mapping Method here

abstract class Mappable extends Identifiable {
  Map<String, dynamic> data;

  Mappable.fromDocument(DocumentSnapshot doc) : super(doc.documentID) {
    setUpVariables();
    mapFrom(doc.data);
  }

  Mappable.fromUID(uid) : super(uid) {
    setUpVariables();
    Firestore.instance
        .document("${className}/${uid}")
        .snapshots()
        .listen((doc) => this.mapFrom(doc.data));
  }

  void setUpVariables();

  Mappable.fromMap(String uid, Map<String, dynamic> data) : super(uid) {
    setUpVariables();
    map(data);
  }

  // All classes which intends to use MAPPING must implement their Mappable functions here.
  static T mapping<T extends Mappable>(DocumentSnapshot doc) {
    if (T == User) {
      return new User.fromDocument(doc) as T;
    }

    if (T == Category) {
      return new Category.fromDocument(doc) as T;
    }

    if (T == FoodTag) {
      return new FoodTag.fromDocument(doc) as T;
    }

    if (T == OrderItem) {
      return new OrderItem.fromDocument(doc) as T;
    }

    if (T == Order) {
      return new Order.fromDocument(doc) as T;
    }


    if (T == Voucher) {
      return new Voucher.fromDocument(doc) as T;
    }

    if (T == Route) {
      return new Route.fromDocument(doc) as T;
    }

    throw FatalError("Mappable Not Declared");
  }

  void mapFrom(Map<String, dynamic> data) {
    this.data = data;

    if (data == null) {
      map(Map());
    } else {
      map(data);
    }
  }

  //standardization className.
  String get className => this.runtimeType.toString().toLowerCase() + "s";

  //To be implemented by Sub-class to take data from Map
  void map(Map<String, dynamic> data);
}
