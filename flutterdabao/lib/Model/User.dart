import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';

class User extends FirebaseType {

  static String foodTagKey = 'FT';
  static String profileImageKey = 'PI';
  static String nameKey = "N";
  static String handPhoneKey = 'HP';
  static String emailKey = 'E';
  static String thumbnailImageKey = 'TI';
  static String creationTime = 'CT';
  static String lastLoginTime = 'LLT';


  BehaviorSubject<String> email; 
  BehaviorSubject<String> profileImage;
  BehaviorSubject<String> name;
  BehaviorSubject<String> handPhone;
  BehaviorSubject<String> thumbnailImage;
  BehaviorSubject<List<FoodTag>> userFoodTags; 


  User.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);
  User.fromUID(String uid) : super.fromUID(uid);

  User.fromAuth(FirebaseUser user) : super.fromUID(user.uid) {
    ConfigHelper.instance.currentUserProperty.value = this;
    //Map<String, String> data = Map<String, String>();

    // data["email"] = user.email;

    // Firestore.instance
    // .collection(this.className).document(uid).updateData(data);
  }

  @override
  void setUpVariables() {
    email = BehaviorSubject();
    profileImage = BehaviorSubject();
    name = BehaviorSubject();
    thumbnailImage = BehaviorSubject();
    userFoodTags = BehaviorSubject(seedValue: List());
    handPhone = BehaviorSubject();
  }

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey(foodTagKey)){
      var mapOfFoodTag = data[foodTagKey] as Map;
      List<FoodTag> fT = List();

      mapOfFoodTag.forEach((key,rawMap){
        var map = rawMap.cast<String,dynamic>();
        fT.add(FoodTag.fromMap(key, map));
      });

      userFoodTags.add(fT);
    } else {
      userFoodTags.add(List());
    }

    if (data.containsKey(emailKey)) {
      email.add(data[emailKey]);
    } else {
      email.add(null);
    }

    if (data.containsKey(profileImageKey)) {
      profileImage.add(data[profileImageKey]);
      //print("PI added");
    } else {
      profileImage.add(null);
      //print("PI null");
    }

    if (data.containsKey(thumbnailImageKey)) {
      thumbnailImage.add(data[thumbnailImageKey]);
    } else {
      thumbnailImage.add(null);
    }

    if (data.containsKey(nameKey)) {
      name.add(data[nameKey]);
      //print("name added");
    } else {
      name.add(null);
      //print("name null");
    }

    if (data.containsKey(handPhoneKey)) {
      handPhone.add(data[handPhoneKey]);
      //print("hp added");
    } else {
      handPhone.add(null);
      //print("hp null");
    }


  }

  void setPhoneNumber(String phoneNumber) {
    Firestore.instance
        .collection(className)
        .document(uid)
        .setData({handPhoneKey: phoneNumber}, merge: true);
  }

    void setEmail(String email) {
    Firestore.instance
        .collection(className)
        .document(uid)
        .setData({emailKey: email}, merge: true);
  }

  //last login date
  //creation date
  void setUser(String pi, String name,int creationTime, int lastLoginTime, String tn) {
    Firestore.instance.collection('/users').document(uid).setData({
      profileImageKey: pi,
      thumbnailImageKey: tn,
      nameKey: name,
      "CT": DateTimeHelper.convertTimeToString(creationTime),
      'LLT': DateTimeHelper.convertTimeToString(lastLoginTime),
    },
    merge: true);
  }
}
