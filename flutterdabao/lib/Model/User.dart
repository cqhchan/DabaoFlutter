

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';

class User extends FirebaseType {



  BehaviorSubject<String> email; 
  BehaviorSubject<double> amountSaved; 
  BehaviorSubject<double> amountEarned; 
  BehaviorSubject<String> profileImage;
  BehaviorSubject<String> name;
  BehaviorSubject<String> handPhone;
  BehaviorSubject<String> thumbnailImage;

  User.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);
  User.fromUID(String uid) : super.fromUID(uid);


  User.fromAuth(FirebaseUser user):super.fromUID(user.uid){
    ConfigHelper.instance.currentUserProperty.value = this;
    //Map<String, String> data = Map<String, String>();

    // data["email"] = user.email;

    // Firestore.instance
        // .collection(this.className).document(uid).updateData(data);
  }

  
  @override
  void setUpVariables() {

    email = BehaviorSubject();
    amountEarned = BehaviorSubject();
    amountSaved = BehaviorSubject();
    profileImage = BehaviorSubject();
    name = BehaviorSubject();
    thumbnailImage = BehaviorSubject();
    handPhone = BehaviorSubject();

  }

  @override
  void map(Map<String, dynamic> data) {

    if (data.containsKey("email")){
      email.add(data["email"]);
    } else {
      email.add(null);
    }

    if (data.containsKey("save")){
      amountSaved.add(data["save"].toDouble());
    } else {
      amountSaved.add(null);
    }

    if (data.containsKey("earn")){
      amountEarned.add(data["earn"].toDouble());
    } else {
      amountEarned.add(null);
    }

    if (data.containsKey("PI")) {
      profileImage.add(data["PI"]);
    } else {
      profileImage.add(null);
    }

    if (data.containsKey("tn")) {
      thumbnailImage.add(data["tn"]);
    } else {
      thumbnailImage.add(null);
    }

    if (data.containsKey("name")) {
      name.add(data["name"]);
    } else {
      name.add(null);
    }

    if (data.containsKey("hp")) {
      handPhone.add(data["hp"]);
    } else {
      handPhone.add(null);
    }
  }

  void setPhoneNumber(String phoneNumber) {
    Firestore.instance
    .collection('/users').document(uid)
    .setData({
      'hp': phoneNumber
    });
  }

  //last login date
  //creation date
  void setUser(String email, double save, double earn, String pi, String name,
    int creationTime, int lastLoginTime, String tn) {
    Firestore.instance
        .collection('/users').document(uid)
        .updateData({ 
          'email': email, 
          'save': save,
          'earn': earn,
          'pi': pi,
          'tn': tn,
          'name': name,
          'ct': DateTimeHelper.convertTimeToString(creationTime),
          'llt': DateTimeHelper.convertTimeToString(lastLoginTime),
          });
  }
  /*
  void havePhoneNumber() {
    FirebaseAuth.instance.currentUser().then((user) {
      print(user.phoneNumber);
      Firestore.instance.collection('/users').document(uid).updateData({'hp': user.phoneNumber});
    }).catchError((e) { //reach here because don't have phone number
      print(e);
    });
    
  }*/

  /*
  void updateThumbnail(String tn) {
    Firestore.instance
      .collection('/users').document(uid)
      .updateData({
        'tn': tn
      });
  }
  */
}