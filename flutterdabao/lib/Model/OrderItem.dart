import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:rxdart/subjects.dart';

enum OrderMode { asap, scheduled }

class OrderItem extends FirebaseType {
  static final String titleKey = "T";
  static final String qtyKey = "QTY";
  static final String priceKey = "P";
  static final String descriptionKey = "D";
  static final String boughtKey = "B";

  BehaviorSubject<String> name;
  BehaviorSubject<double> price;
  BehaviorSubject<int> quantity;
  BehaviorSubject<String> description;
  BehaviorSubject<bool> isBought;

  OrderItem.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  @override
  void map(Map<String, dynamic> map) {
    if (map.containsKey(titleKey)) {
      name.add(map[titleKey]);
    } else {
      name.add(null);
    }

    if (map.containsKey(descriptionKey)) {
      description.add(map[descriptionKey]);
    } else {
      description.add(null);
    }

    if (map.containsKey(qtyKey)) {
      quantity.add(map[qtyKey]);
    } else {
      quantity.add(0);
    }

    if (map.containsKey(priceKey)) {
      price.add(map[priceKey] + .0);
    } else {
      price.add(null);
    }

    if (map.containsKey(boughtKey)) {
      isBought.add(map[boughtKey]);
    } else {
      isBought.add(false);
    }
  }

  updateBought(Order order, bool bought) {
    Firestore.instance
        .collection(order.className)
        .document(order.uid)
        .collection(this.className)
        .document(this.uid)
        .updateData({boughtKey: bought});
  }

  @override
  void setUpVariables() {
    name = BehaviorSubject();
    quantity = BehaviorSubject();
    price = BehaviorSubject();
    description = BehaviorSubject();
    isBought = BehaviorSubject();
  }
}
