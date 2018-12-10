import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
  
  
const String kGoogleApiKey = "AIzaSyCIIqjYS-TEsb7XziWv79Z9kEmZ-m-u2mk";

abstract class HavingGoogleMapPlaces {

  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

    Future<LatLng> getLatLng(Prediction p) async {
      assert (p != null);

      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      
      return LatLng(lat, lng);
  }
}