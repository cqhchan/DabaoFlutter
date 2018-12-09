
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class FontHelper {


  static const TextStyle placeholderTextStyle = TextStyle(color: Colors.grey, fontSize: 13.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w600, fontFamily: "SF_UI_Display") ;
  static const TextStyle normalTextStyle = TextStyle(color: Colors.black, fontSize: 12.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w300, fontFamily: "SF_UI_Display") ;
  static const TextStyle chipTextStyle = TextStyle(color: Colors.orange, fontSize: 12.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w300, fontFamily: "SF_UI_Display") ;
  static const TextStyle headerTextStyle = TextStyle(color: Colors.black, fontSize: 30.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w600, fontFamily: "SF_UI_Display") ;
  static const TextStyle header2TextStyle = TextStyle(color: Colors.black, fontSize: 22.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w600, fontFamily: "SF_UI_Display") ;
  static const TextStyle semiBold14Black = TextStyle(color: Colors.black, fontSize: 14.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w600, fontFamily: "SF_UI_Display") ;
  static const TextStyle semiBold16Black = TextStyle(color: Colors.black, fontSize: 16.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w600, fontFamily: "SF_UI_Display") ;
  static const TextStyle semiBold18Black = TextStyle(color: Colors.black, fontSize: 18.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w600, fontFamily: "SF_UI_Display") ;
  static const TextStyle semiBold20Orange = TextStyle(color: ColorHelper.dabaoOrange, fontSize: 20.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w600, fontFamily: "SF_UI_Display") ;

  static const TextStyle regular14Black = TextStyle(color: Colors.black, fontSize: 12.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w400, fontFamily: "SF_UI_Display") ;
  static const TextStyle bold14Black = TextStyle(color: Colors.black, fontSize: 14.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w700, fontFamily: "SF_UI_Display") ;

  static TextStyle semiBold16(Color color) {
  return TextStyle(color: color, fontSize: 16.0, fontStyle: FontStyle.normal,fontWeight: FontWeight.w600, fontFamily: "SF_UI_Display") ;
  }

  static TextStyle regular(Color color, double size) {
  return TextStyle(color: color, fontSize: size, fontStyle: FontStyle.normal,fontWeight: FontWeight.w400, fontFamily: "SF_UI_Display") ;
  }

}