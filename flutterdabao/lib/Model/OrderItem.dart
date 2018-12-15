import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/subjects.dart';

class OrderItem extends FirebaseType {
  static final String titleKey = "T";
  static final String qtyKey = "QTY";
  static final String priceKey = "P";
  static final String descriptionKey = "D";

  BehaviorSubject<String> name;
  BehaviorSubject<double> price;
  BehaviorSubject<int> quantity;
  BehaviorSubject<String> description;

  OrderItem.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  @override
  void map(Map<String, dynamic> map) {
    
    print (map);
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
      price.add(0.0);
    }
  }

  @override
  void setUpVariables() {
    name = BehaviorSubject();
    quantity = BehaviorSubject();
    price = BehaviorSubject();
    description = BehaviorSubject();
  }
}
