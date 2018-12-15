

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';

class User extends FirebaseType {

  static String foodTagKey = 'FT';

  BehaviorSubject<String> email; 
  BehaviorSubject<double> amountSaved; 
  BehaviorSubject<double> amountEarned; 
  BehaviorSubject<String> profileImage;
  BehaviorSubject<String> name;
  BehaviorSubject<String> phoneNumber;
  BehaviorSubject<String> thumbnailImage;
  BehaviorSubject<List<FoodTag>> userFoodTags; 

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
    phoneNumber = BehaviorSubject();
    thumbnailImage = BehaviorSubject();
    userFoodTags = BehaviorSubject(seedValue: List());

  }

  @override
  void map(Map<String, dynamic> data) {
      print(data);

    if (data.containsKey(foodTagKey)){
      var mapOfFoodTag = data[foodTagKey] as Map;
      List<FoodTag> fT = List();


      print(mapOfFoodTag);
      mapOfFoodTag.forEach((key,rawMap){
        var map = rawMap.cast<String,dynamic>();
        fT.add(FoodTag.fromMap(key, map));
      });
            print("testing" + fT.length.toString());

      userFoodTags.add(fT);
    } else {
      userFoodTags.add(List());
    }


    if (data.containsKey("email")){
      email.add(data["email"]);
    }

    if (data.containsKey("PI")) {
      profileImage.add(data["PI"]);
    }

    if (data.containsKey("tn")) {
      thumbnailImage.add(data["tn"]);
    }

    if (data.containsKey("name")) {
      profileImage.add(data["name"]);
    } else {

      profileImage.add(null);
    }
    if (data.containsKey("hp")) {
      profileImage.add(data["hp"]);
    }

  }
  //last login date
  //creation date
  void setUser(String email, double save, double earn, String pi, String name, String hp, 
    int creationTime, int lastLoginTime, String tn) {
    Firestore.instance
        .collection('/users').document(uid)
        .setData({ 
          'email': email, 
          'save': save,
          'earn': earn,
          'pi': pi,
          'tn': tn,
          'name': name,
          'hp': hp,
          'ct': DateTimeHelper.convertTimeToString(creationTime),
          'llt': DateTimeHelper.convertTimeToString(lastLoginTime)
          });
  }
  /*
  String convertTimeToString(int time) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(time * 1000), 
      [dd, '-', mm, '-', yyyy, ' ', HH, ':', nn, ':', ss, ' ', z]);
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