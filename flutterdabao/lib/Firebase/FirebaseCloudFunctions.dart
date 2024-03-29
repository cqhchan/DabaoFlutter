import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Wallet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  static Future<List<String>> fetchProximityHash({
    @required LatLng location,
    int radius = 500,
  }) async {
    List<String> list = List();
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["lat"] = location.latitude;
      attributeMap["long"] = location.longitude;
      attributeMap["radius"] = radius;
      attributeMap["mode"] = 4;
      print('requesting fetchProximityHash from functions');
      Map<dynamic, dynamic> results = await CloudFunctions.instance
          .call(functionName: 'locationRequest', parameters: attributeMap);
      print(results);

      if (results.containsKey("geohashes")) {
        list = List.castFrom<dynamic, String>(results["geohashes"]);
      }

      print(list.length);
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print('Error: $e');
    }

    return list;
  }

  ///[location] Location to search
  ///[radius] radius in meters to search default 500
  static Future<List<FoodTag>> fetchNearbyDeliveryFoodTags({
    @required LatLng location,
    @required DateTime startTime,
    DateTime endTime,
    int radius = 300,
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
      print('requesting fetchNearbyDeliveryFoodTags from functions');
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
    int limit = 8,
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
    @required Map<String, dynamic> data,
  }) async {
    try {
      data["mode"] = 0;
      Map<dynamic, dynamic> results = await CloudFunctions.instance
          .call(functionName: 'creationRequest', parameters: data);
      print(results);

      if (results.containsKey("status") && results["status"] == 200)
        return true;
    } on CloudFunctionsException catch (e) {
      print(e.message);
      print(e);
    } catch (e) {
      print('Error: $e');
    }

    return false;
  }

  ///[data] data of an Order
  static Future<bool> redeemVoucher({
    @required String voucherID,
    @required String userID,
  }) async {
    Map<dynamic, dynamic> results = Map();
    try {
      Map<String, dynamic> data = Map();
      data["mode"] = 0;
      data["voucherID"] = voucherID;
      data["userID"] = userID;

      results = await CloudFunctions.instance
          .call(functionName: 'addRequests', parameters: data);
    } on CloudFunctionsException catch (e) {
      print(e.message);
      print(e);
    } catch (e) {
      print('Error: $e');
    }
    print(results);

    if (results.containsKey("status") && results["status"] == 200) return true;

    throw new PlatformException(
        code: results["status"].toString(), message: results["message"]);
  }

  ///[data] data of an Order
  static Future<bool> cancelCurrentUserOrder({
    @required String orderID,
  }) async {
    Map<dynamic, dynamic> results = Map();
    try {
      Map<String, dynamic> data = Map();
      data["mode"] = 4;
      data["orderID"] = orderID;

      results = await CloudFunctions.instance
          .call(functionName: 'creationRequest', parameters: data);
    } on CloudFunctionsException catch (e) {
      print(e.message);
      print(e);
    } catch (e) {
      print('Error: $e');
    }
    print(results);

    if (results.containsKey("status") && results["status"] == 200) return true;

    throw new PlatformException(
        code: results["status"].toString(), message: results["message"]);
  }

  ///[data] data of an Order
  static Future<bool> cancelDeliveringOrder({
    @required String orderID,
  }) async {
    Map<dynamic, dynamic> results = Map();
    try {
      Map<String, dynamic> data = Map();
      data["mode"] = 5;
      data["orderID"] = orderID;

      results = await CloudFunctions.instance
          .call(functionName: 'creationRequest', parameters: data);
    } on CloudFunctionsException catch (e) {
      print(e.message);
      print(e);
    } catch (e) {
      print('Error: $e');
    }
    print(results);

    if (results.containsKey("status") && results["status"] == 200) return true;

    throw new PlatformException(
        code: results["status"].toString(), message: results["message"]);
  }

  ///[double] amount of an Order
  ///[userID] the id of the current user
  static Future<bool> requestWithdrawal({
    @required double amount,
    @required String userID,
    @required WithdrawalAccount account
  }) async {
    Map<dynamic, dynamic> results = Map();
    try {
      Map<String, dynamic> data = Map();
      data["mode"] = 1;
      data["amount"] = amount;
      data["userID"] = userID;
      data["accountData"] = account.data;

      results = await CloudFunctions.instance
          .call(functionName: 'addRequests', parameters: data);
    } on CloudFunctionsException catch (e) {
      print(e.message);
      print(e);
    } catch (e) {
      print('Error: $e');
    }
    print(results);

    if (results.containsKey("status") && results["status"] == 200) return true;

    throw new PlatformException(
        code: results["status"].toString(), message: results["message"]);
  }

  ///[data] data of an Route
  static Future<bool> createRoute({
    @required Map<String, dynamic> data,
  }) async {
    try {
      data["mode"] = 1;
      Map<dynamic, dynamic> results = await CloudFunctions.instance
          .call(functionName: 'creationRequest', parameters: data);
      print(results);

      if (results.containsKey("status") && results["status"] == 200)
        return true;
    } on CloudFunctionsException catch (e) {
      print(e.message);
      print(e);
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }

    return false;
  }

  ///[data] acceptOrder
  /// orderID
  /// acceptorID
  /// deliveryTime
  /// routeID Optional
  /// deliveryfee Optional

  static Future<bool> acceptOrder(
      {@required String orderID,
      @required String acceptorID,
      @required String deliveryTime,
      String routeID,
      double deliveryFee}) async {
    Map<dynamic, dynamic> results = Map();

    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["mode"] = 2;
      attributeMap["orderID"] = orderID;
      attributeMap["acceptorID"] = acceptorID;
      attributeMap["deliveryTime"] = deliveryTime;
      attributeMap["deliveryFee"] = deliveryFee;

      if (routeID != null) attributeMap["routeID"] = routeID;

      results = await CloudFunctions.instance
          .call(functionName: 'creationRequest', parameters: attributeMap);
      print(results);
    } on CloudFunctionsException catch (e) {
      print(e.message);
      print(e);
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
    if (results.containsKey("status") && results["status"] == 200) return true;

    throw new PlatformException(
        code: results["status"].toString(), message: results["message"]);
  }

  ///[data] acceptOrder
  /// orderID
  /// acceptorID
  /// completedTime
  static Future<bool> completeOrder({
    @required String orderID,
    @required String acceptorID,
    @required String completedTime,
  }) async {
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["mode"] = 3;
      attributeMap["orderID"] = orderID;
      attributeMap["acceptorID"] = acceptorID;
      attributeMap["completedTime"] = completedTime;

      Map<dynamic, dynamic> results = await CloudFunctions.instance
          .call(functionName: 'creationRequest', parameters: attributeMap);
      print(results);

      if (results.containsKey("status") && results["status"] == 200)
        return true;

      if (results.containsKey("status") && results["status"] == 400)
        return false;
    } on CloudFunctionsException catch (e) {
      print(e.message);
      print(e);
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }

    return false;
  }
}
