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
    setUpVariables();
    mapFrom(doc.data);
  }

  Mappable.fromUID(uid) : super(uid){
    setUpVariables();
    Firestore.instance.document("${className}/${uid}").snapshots().listen((doc) => this.mapFrom(doc.data));
  }

  void setUpVariables();

  // All classes which intends to use MAPPING must implement their Mappable functions here.
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
    if (data!= null) {
    map(data);
    } 
    map(Map());
  }
  
  //standardization className.
  String get className => this.runtimeType.toString().toLowerCase() + "s";

  
  //To be implemented by Sub-class to take data from Map
  void map(Map<String, dynamic> data);
}

