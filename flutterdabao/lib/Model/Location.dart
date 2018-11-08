

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';

class Location extends FirebaseType {

  GeoPoint point;
  

  Location.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  // TODO: implement className
  @override
  String get className => this.runtimeType.toString().toLowerCase() + "s";

  @override
  void map(Map<String,dynamic> data) {
    point = data["coordinates"];
  }



}