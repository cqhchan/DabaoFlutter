import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geohash/geohash.dart';

class FirebaseCloudFunctions {
  ///[location] Location to search
  ///[radius] radius in meters to search default 500
  static Future<List<LatLng>> fetchNearbyOrder({
    @required LatLng location,
    int radius = 500,
  }) async {
    List<LatLng> listOfMarkers = List();
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["lat"] = location.latitude;
      attributeMap["long"] = location.longitude;
      attributeMap["radius"] = radius;
      attributeMap["mode"] = 1;
      print('requesting from functions');
      final result = await CloudFunctions.instance
          .call(functionName: 'locationRequest', parameters: attributeMap);

      result['locations'].forEach((latlng) {
        double latitude = latlng[0];
        double longitude = latlng[1];
        listOfMarkers.add(LatLng(latitude, longitude));
      });
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print('Error: $e');
    }

    return listOfMarkers;
  }

  ///[location] Location to search
  ///[radius] radius in meters to search default 500
  static Future<List<LatLng>> fetchNearbyDeliveries({
    @required LatLng location,
    int radius = 500,
  }) async {
    List<LatLng> listOfMarkers = List();
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["lat"] = location.latitude;
      attributeMap["long"] = location.longitude;
      attributeMap["radius"] = radius;
      attributeMap["mode"] = 0;
      print('requesting from functions');
      final result = await CloudFunctions.instance
          .call(functionName: 'locationRequest', parameters: attributeMap);

      result['locations'].forEach((latlng) {
        double latitude = latlng[0];
        double longitude = latlng[1];
        listOfMarkers.add(LatLng(latitude, longitude));
      });
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print('Error: $e');
    }

    return listOfMarkers;
  }

  ///[location] Location to search
  ///[radius] radius in meters to search default 1000
  static Future<List<FoodTag>> fetchNearbyFoodTags({
    @required LatLng location,
    int radius = 1000,
  }) async {
    List<FoodTag> list = List();
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["lat"] = location.latitude;
      attributeMap["long"] = location.longitude;
      attributeMap["radius"] = radius;
      attributeMap["mode"] = 2;
      print('requesting foodTags from functions');
      Map<dynamic, dynamic> results = await CloudFunctions.instance
          .call(functionName: 'locationRequest', parameters: attributeMap);
      print(results);

      results.forEach((key, dataRaw) {
        Map<String, dynamic> data = dataRaw.cast<String, dynamic>();
        list.add(FoodTag.fromMap(key, data));
      });

      print(list.length);
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print('Error: $e');
    }

    return list;
  }

  ///[location] Location to search
  ///[radius] radius in meters to search default 1000
  static Future<List<FoodTag>> fetchNearbyDeliveryFoodTags({
    @required LatLng location,
    @required DateTime startTime,
    DateTime endTime,
    int radius = 1000,
  }) async {
    List<FoodTag> list = List();
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["lat"] = location.latitude;
      attributeMap["long"] = location.longitude;
      attributeMap["ST"] = DateTimeHelper.convertDateTimeToString(startTime);

      if (endTime != null)
      attributeMap["ET"] = DateTimeHelper.convertDateTimeToString(endTime);

      attributeMap["radius"] = radius;
      attributeMap["mode"] = 3;
      print('requesting foodTags from functions');
      Map<dynamic, dynamic> results = await CloudFunctions.instance
          .call(functionName: 'locationRequest', parameters: attributeMap);
      print(results);

      results.forEach((key, dataRaw) {
        Map<String, dynamic> data = dataRaw.cast<String, dynamic>();
        list.add(FoodTag.fromMap(key, data));
      });

      print(list.length);
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print('Error: $e');
    }

    return list;
  }


  ///[foodTagTitle] foodTag To Search
  ///[limit] limit number of Suggested Food Type
  static Future<List<OrderItem>> fetchOrderItemForFoodTag({
    @required String foodTagTitle,
    int limit = 5,
  }) async {
    return FirebaseCollectionReactiveOnce<OrderItem>(Firestore.instance
            .collection("foodTags")
            .document(foodTagTitle.toLowerCase())
            .collection("orderItems")
            .orderBy(FoodTag.qtyKey, descending: true)
            .limit(limit))
        .future;
  }


    ///[data] data of an Order
  static Future<bool> createOrder({
    @required Map<String,dynamic> data,
  }) async {
    try {
      data["mode"] = 0;
      print("testing Order create 5 ");
      Map<dynamic, dynamic> results = await CloudFunctions.instance
          .call(functionName: 'creationRequest', parameters: data);
      print(results);

            print("testing Order create 6 ");

      if (results.containsKey("status") && results["status"] == 200)
      return true;

    } on CloudFunctionsException catch (e) {
            print("testing Order create 7 ");
      
      print(e.message);
      print(e);

    } catch (e) {
           print("testing Order create 8 ");
 
      print('Error: $e');
    }

    return false;
  }

}




