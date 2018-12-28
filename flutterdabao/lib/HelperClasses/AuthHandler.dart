import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';

class AuthHandler {

  String smsCode;
  String verificationId;

  //////////////////////////////////////////////////////////////
  //////MOBILE LOGIN AND SIGN UP/////////////////////////////////
  /////////////////////////////////////////////////////////////////
  Future<void> verifyPhone({String phoneNumber, VoidCallback smsSent, Function(FirebaseUser user) success, Function(dynamic e) failed,  bool linkCredentials}) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      print("sent");
      verificationId = verId;
      smsSent();
    };
    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      success(user);
    };
    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print(exception.code.toString());
      print(exception.message.toString());

      failed(exception);
    };
    try{
    await FirebaseAuth.instance.verifyPhoneNumber(
        linkCredentials: linkCredentials,
        phoneNumber: phoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed).catchError((e){
          failed(e);
        } );
    } catch( e){
          failed(e);
    }
   }

  //CAUTION!! This can shall only be called after OTP is sent, otherwise, app will crash
  Future<FirebaseUser> signInWithPhone() async {
    return FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.getCredential(
            verificationId: verificationId, smsCode: smsCode));
  }

    //CAUTION!! This can shall only be called after OTP is sent, otherwise, app will crash
  Future<FirebaseUser> linkCredentialsWithPhone() async {
    return FirebaseAuth.instance
        .linkWithCredential(PhoneAuthProvider.getCredential(
            verificationId: verificationId, smsCode: smsCode));
  }
}