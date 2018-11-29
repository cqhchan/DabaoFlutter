

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';

class Location extends FirebaseType {

  GeoPoint point;
  

  Location.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  

  @override
  void map(Map<String,dynamic> data) {
    point = data["coordinates"];
  }

  @override
  void setUpVariables() {
    // TODO: implement setUpVariables
  }



}