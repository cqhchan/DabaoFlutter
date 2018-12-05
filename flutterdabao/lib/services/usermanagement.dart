import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class UserManagement {
  /*
  storeNewUser(user, context) {
    Firestore.instance.collection('/users').add({
      'email': user.email,
      'name': user.name,
      'uid': user.uid,
      'earn': user.earn,
      'save': user.save,
      'PI': user.pi, //profileImage URL
      'hp': user.phoneNumber,
    }).then((value) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/selectpic');
    }).catchError((e) {
      print(e);
    });
  }*/


  /*
   * For updating profile picture (NOT IN USE RIGHT NOW)
   */

  /*
  Future updateProfilePic(picUrl) async {
    var userInfo = new UserUpdateInfo();
    userInfo.photoUrl = picUrl;

    FirebaseAuth.instance.updateProfile(userInfo).then((val){
      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance.collection('/users')
        .where('uid', isEqualTo: user.uid)
        .getDocuments()
        .then((docs) {
          Firestore.instance.document('/users/${docs.documents[0].documentID}')
          .updateData({'PI': picUrl}).then((val) {
            print('Updated');
          }).catchError((e) {
            print(e);
          });
        }).catchError((e) {
          print(e);
        });
      }).catchError((e) {
        print(e);
      });
    }).catchError((e) {
      print(e);
    });
  }
  */
}