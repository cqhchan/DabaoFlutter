import 'package:flutterdabao/ExtraProperties/Equatable.dart';
import 'package:flutterdabao/ExtraProperties/Identifiable.dart';
import 'package:flutterdabao/ExtraProperties/Mappable.dart';
import 'package:quiver/core.dart';



class FirebaseType extends Identifiable with Equatable, Mappable {
  

  FirebaseType(String uid) : super(uid);
  
  
  @override
  int generateHashCode() => hash2(this.runtimeType.toString().hashCode,uid.hashCode);
  

  @override
  bool isEqual(Object o) {
       print("RunTime Name" +  this.runtimeType.toString());
       print("Object Name" +  o.runtimeType.toString());

    if ( o.runtimeType ==  this.runtimeType) {

      return (o as FirebaseType).uid == this.uid;

    } else {
      return false;
    }

     
  }


}

class FirebaseKeyHelper {

  static const  String userKey = "users"; 


}