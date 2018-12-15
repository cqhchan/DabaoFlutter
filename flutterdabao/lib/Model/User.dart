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
  BehaviorSubject<String> handPhone;
  BehaviorSubject<String> thumbnailImage;
  BehaviorSubject<List<FoodTag>> userFoodTags; 
  //this verified boolean helps ensure old user's phone number is verified
  //new users are set to verified = true by default
  BehaviorSubject<bool> verified;

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
    amountEarned = BehaviorSubject();
    amountSaved = BehaviorSubject();
    profileImage = BehaviorSubject();
    name = BehaviorSubject();
    thumbnailImage = BehaviorSubject();
    userFoodTags = BehaviorSubject(seedValue: List());

    handPhone = BehaviorSubject();
    verified = BehaviorSubject();
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

    if (data.containsKey("email")) {
      email.add(data["email"]);
    } else {
      email.add(null);
    }

    if (data.containsKey("save")) {
      amountSaved.add(data["save"].toDouble());
    } else {
      amountSaved.add(null);
    }

    if (data.containsKey("earn")) {
      amountEarned.add(data["earn"].toDouble());
    } else {
      amountEarned.add(null);
    }

    if (data.containsKey("PI")) {
      profileImage.add(data["PI"]);
      //print("PI added");
    } else {
      profileImage.add(null);
      //print("PI null");
    }

    if (data.containsKey("tn")) {
      thumbnailImage.add(data["tn"]);
    } else {
      thumbnailImage.add(null);
    }

    if (data.containsKey("name")) {
      name.add(data["name"]);
      //print("name added");
    } else {
      name.add(null);
      //print("name null");
    }

    if (data.containsKey("hp")) {
      handPhone.add(data["hp"]);
      //print("hp added");
    } else {
      handPhone.add(null);
      //print("hp null");
    }

    if (data.containsKey("verified")) {
      verified.add(data["verified"]);
    } else {
      verified.add(false);
    }
  }

  void setPhoneNumber(String phoneNumber) {
    Firestore.instance
        .collection('/users')
        .document(uid)
        .setData({'hp': phoneNumber, 'verified': true}, merge: true);
  }

  //last login date
  //creation date
  void setUser(String email, double save, double earn, String pi, String name,
      int creationTime, int lastLoginTime, String tn, String handPhone) {
    Firestore.instance.collection('/users').document(uid).setData({
      'email': email,
      'save': save,
      'earn': earn,
      'pi': pi,
      'tn': tn,
      'name': name,
      'hp': handPhone,
      'ct': DateTimeHelper.convertTimeToString(creationTime),
      'llt': DateTimeHelper.convertTimeToString(lastLoginTime),
      'verified': true, 
    },
    merge: true);
  }
}
