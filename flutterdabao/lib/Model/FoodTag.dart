import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:rxdart/rxdart.dart';

class FoodTag extends FirebaseType with Selectable{

static final String geoHashKey = "GH";
static final String titleKey = "T";
static final String promoKey = 'P';
static final String reccomendedKey = 'R';
static final String qtyKey = 'QTY';
static final String lastUsedKey = 'LU';


  BehaviorSubject<String> title;
  BehaviorSubject<int> quantity;
  BehaviorSubject<String> promo;
  BehaviorSubject<bool> reccomended;
  BehaviorSubject<String> lastUsed;


  FoodTag.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  FoodTag.fromUID(String uid) : super.fromUID(uid);

  FoodTag.fromMap(String uid, Map<String, dynamic> data) : super.fromMap(uid, data);

  
  @override
  void map(Map<String,dynamic> data) {
  
   if (data.containsKey(titleKey)){
      title.add(data[titleKey]);
    } else {
      title.add(null);
    }

   if (data.containsKey(qtyKey)){
      quantity.add(data[qtyKey]);
    } else {
      quantity.add(0);
    }   

    if (data.containsKey(lastUsedKey)){
      lastUsed.add(data[lastUsedKey]);
    } else {
      lastUsed.add(null);
    }   
    
    if (data.containsKey(reccomendedKey)){
      reccomended.add(data[reccomendedKey]);
    } else {
      reccomended.add(false);
    }   
    
    if (data.containsKey(promoKey)){
      promo.add(data[promoKey]);
    } else {
      promo.add(null);
    }
  }

  @override
  void setUpVariables() {

    title = BehaviorSubject();
    quantity = BehaviorSubject();
    reccomended = BehaviorSubject();
    promo = BehaviorSubject();
    lastUsed = BehaviorSubject();

  }

}