import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/Equatable.dart';
import 'package:flutterdabao/ExtraProperties/Identifiable.dart';
import 'package:flutterdabao/ExtraProperties/Mappable.dart';
import 'package:quiver/core.dart';



abstract class FirebaseType extends Mappable with Equatable {
  

  FirebaseType.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);
  
  FirebaseType.fromUID(String uid) : super.fromUID(uid);


  @override
  int generateHashCode() => hash2(this.runtimeType.toString().hashCode,uid.hashCode);
  

  @override
  bool isEqual(Object o) {

    if ( o.runtimeType ==  this.runtimeType) {

      return (o as FirebaseType).uid == this.uid;

    } else {
      return false;

    }

  }

  
}
