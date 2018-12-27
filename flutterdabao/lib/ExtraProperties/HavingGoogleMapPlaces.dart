import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
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

    Future<void> handlePressButton(BuildContext context,Function(LatLng,String) onCompleteCallback) async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.fullscreen,
      language: "en",
      components: [Component(Component.country, "sg")],
    );

    if (p != null) {
      LatLng newLocation = await getLatLng(p);
      onCompleteCallback(newLocation, p.description);

    }
  }

  void onError(PlacesAutocompleteResponse response) {
    SnackBar(content: Text(response.errorMessage));
  }
}