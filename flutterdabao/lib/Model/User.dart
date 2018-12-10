

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:rxdart/rxdart.dart';

class User extends FirebaseType {



  BehaviorSubject<String> email; 
  BehaviorSubject<double> amountSaved; 
  BehaviorSubject<double> amountEarned; 


  User.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);
  User.fromUID(String uid) : super.fromUID(uid);


  User.fromAuth(FirebaseUser user):super.fromUID(user.uid){
    ConfigHelper.instance.currentUserProperty.value = this;
    Map<String, String> data = Map<String, String>();

    data["email"] = user.email;

    Firestore.instance
        .collection(this.className).document(uid).setData(data, merge: true);
    

  }

  
  @override
  void setUpVariables() {

    email = BehaviorSubject();
    amountEarned = BehaviorSubject();
    amountSaved = BehaviorSubject();


  }

  @override
  void map(Map<String, dynamic> data) {

    // if (data.containsKey("email")){
    //   email.add(data["email"]);
    // }

    // if (data.containsKey("save")){
    //   amountSaved.add(data["save"].toDouble());
    // }

    // if (data.containsKey("earn")){
    //   amountEarned.add(data["earn"].toDouble());
    // }

  }


}