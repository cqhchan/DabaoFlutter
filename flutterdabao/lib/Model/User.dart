

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';

class User extends FirebaseType {



  String email;

  User.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);
  User.fromUID(String uid) : super.fromUID(uid);


  User.fromAuth(FirebaseUser user):super.fromUID(user.uid){
    ConfigHelper.instance.currentUserProperty.value = this;
    
    Map<String, String> data = Map<String, String>();
    
    data["email"] = user.email;

    Firestore.instance
        .collection(this.className).document(uid).setData(data);
      
  }



  @override
  void map(Map<String, dynamic> data) {

  email = data["email"];
  print(email);


  }


}