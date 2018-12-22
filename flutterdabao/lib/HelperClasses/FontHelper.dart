import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class FontHelper {
  static const TextStyle semiBoldgrey12TextStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14.0,
      fontStyle: FontStyle.normal,
      fontFamily: "SF_UI_Display");
  static const TextStyle fadeTextStyle = TextStyle(
      color: Colors.grey,
      fontSize: 12.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
  static const TextStyle subtitleTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 9.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
  static const TextStyle placeholderTextStyle = TextStyle(
      color: Colors.grey,
      fontSize: 13.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
  static const TextStyle normalTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 12.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w300,
      fontFamily: "SF_UI_Display");
  static const TextStyle normal2TextStyle = TextStyle(
      color: Colors.black,
      fontSize: 11.5,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");
  static const TextStyle chipTextStyle = TextStyle(
      color: Colors.orange,
      fontSize: 12.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
  static const TextStyle headerTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 30.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
  static const TextStyle overlayHeader = TextStyle(
      color: Colors.black,
      fontSize: 16.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontFamily: "SF_UI_Display");
  static const TextStyle medium14TextStyle = TextStyle(
      color: Colors.black,
      fontSize: 13.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontFamily: "SF_UI_Display");
      static const TextStyle medium10TextStyle = TextStyle(
      color: Colors.black,
      fontSize: 10.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontFamily: "SF_UI_Display");
      static const TextStyle medium12TextStyle = TextStyle(
      color: Colors.grey,
      fontSize: 12.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");
  static const TextStyle overlaySubtitleHeader = TextStyle(
      color: ColorHelper.dabaoOffBlack9B,
      fontSize: 14.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontFamily: "SF_UI_Display");
  static const TextStyle header2TextStyle = TextStyle(
      color: Colors.black,
      fontSize: 22.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
  static const TextStyle header3TextStyle = TextStyle(
      color: Colors.black,
      fontSize: 18.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");
  static const TextStyle semiBold14Black = TextStyle(
      color: Colors.black,
      fontSize: 14.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
      static const TextStyle semiBold14Black2 = TextStyle(
      color: Colors.black,
      fontSize: 14.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");
  static const TextStyle semiBold16Black = TextStyle(
      color: Colors.black,
      fontSize: 16.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");
  static const TextStyle semiBold18Black = TextStyle(
      color: Colors.black,
      fontSize: 18.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
  static const TextStyle semiBold20Orange = TextStyle(
      color: ColorHelper.dabaoOrange,
      fontSize: 20.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      fontFamily: "SF_UI_Display");
  static const TextStyle regular14Black = TextStyle(
      color: Colors.black,
      fontSize: 12.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");
      static const TextStyle regular10Black = TextStyle(
      color: Colors.black,
      fontSize: 10.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");
      static const TextStyle bold12Black = TextStyle(
      color: Colors.black,
      fontSize: 12.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");
  static const TextStyle bold14Black = TextStyle(
      color: Colors.black,
      fontSize: 14.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w700,
      fontFamily: "SF_UI_Display");
  static const TextStyle bold16Black = TextStyle(
      color: Colors.black,
      fontSize: 16.0,
      fontStyle: FontStyle.normal,
      // fontWeight: FontWeight.w400,
      fontFamily: "SF_UI_Display");

  static TextStyle semiBold(Color color, double fontSize) {
    return TextStyle(
        color: color,
        fontSize: fontSize,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w600,
        fontFamily: "SF_UI_Display");
  }

  static TextStyle semiBold16(Color color) {
    return TextStyle(
        color: color,
        fontSize: 16.0,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w600,
        fontFamily: "SF_UI_Display");
  }

  static TextStyle regular(Color color, double size) {
    return TextStyle(
        color: color,
        fontSize: size,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        fontFamily: "SF_UI_Display");
  }

  static TextStyle bold(Color color, double size) {
    return TextStyle(
        color: color,
        fontSize: size,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w700,
        fontFamily: "SF_UI_Display");
  }

  static TextStyle medium(Color color, double size) {
    return TextStyle(
        color: color,
        fontSize: size,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w500,
        fontFamily: "SF_UI_Display");
  }
}
