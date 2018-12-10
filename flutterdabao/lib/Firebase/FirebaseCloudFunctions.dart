import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseCloudFunctions {
  ///[location] Location to search
  ///[radius] radius in meters to search default 500
  ///[mode] 0 or 1 (0 searches for deliveries, 1 searches for orders)
  Future<List<LatLng>> fetchNearbyOrderOrDeliveries({
    @required LatLng location,
    @required mode,
    int radius = 500,
  }) async {
    List<LatLng> listOfMarkers = List();
    try {
      Map<String, dynamic> attributeMap = new Map<String, dynamic>();
      attributeMap["lat"] = location.latitude;
      attributeMap["long"] = location.longitude;
      attributeMap["radius"] = radius;
      attributeMap["mode"] = mode;
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
}
