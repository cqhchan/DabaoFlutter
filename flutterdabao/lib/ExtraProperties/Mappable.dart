import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/CustomError/FatalError.dart';
import 'package:flutterdabao/ExtraProperties/Identifiable.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/Model/Location.dart';
import 'package:flutterdabao/Model/User.dart';



// ALL MAPPABLE MUST DECLARE THEIR Mapping Method here

  abstract class Mappable extends Identifiable {

  Map<String, dynamic> data;
  
  Mappable.fromDocument(DocumentSnapshot doc) : super(doc.documentID){
    mapFrom(doc.data);
  }

  Mappable.fromUID(uid) : super(uid){
    Firestore.instance.document("${className}/${uid}").snapshots().listen((doc) => this.mapFrom(doc.data));
  }

  static T mapping<T extends Mappable>(DocumentSnapshot doc){

    if (T == User){

      return new User.fromDocument(doc) as T;
    }

    if (T == Location){
      

      return new Location.fromDocument(doc) as T;
    }


    throw FatalError("Mappable Not Declared");
  }


  void mapFrom(Map<String, dynamic> data){
    this.data = data;
    map(data);
  }
  
  
  String get className;

  

  void map(Map<String, dynamic> data);
}

