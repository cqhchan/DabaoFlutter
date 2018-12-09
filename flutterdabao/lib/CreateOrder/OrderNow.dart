import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutterdabao/CreateOrder/FoodTag.dart';
import 'package:flutterdabao/CustomWidget/CustomizedBackButton.dart';
import 'package:flutterdabao/CustomWidget/CustomizedMap.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';

import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:async';

const kGoogleApiKey = "AIzaSyCIIqjYS-TEsb7XziWv79Z9kEmZ-m-u2mk";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class OrderNow extends StatefulWidget {
  _OrderNowState createState() => _OrderNowState();
}

class _OrderNowState extends State<OrderNow> with HavingSubscriptionMixin,SingleTickerProviderStateMixin {
  String _address = '20 Heng Mui Keng Terrace';

  MutableProperty<LatLng> selectedLocation = MutableProperty(null);
  MutableProperty<String> selectedLocationDescription = MutableProperty(null);

  double newLatitude;
  double newLongitude;

  void initState() {
    super.initState();
    subscription.add(selectedLocation.producer.listen((_) {}));
    subscription.add(selectedLocationDescription.producer.listen((_) {}));
  }

  @override
  void dispose() {
    subscription.dispose();
    super.dispose();
  }

  _selectStartTime() {
    final Future<TimeOfDay> pickedStart = showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      print(value.hour);
      _selectEndTime();
    });
  }

  _selectEndTime() {
    final Future<TimeOfDay> pickedEnd = showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      print(value.hour);
    });
  }

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            color: ColorHelper.dabaoOffWhiteF5,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 10.0, color: ColorHelper.dabaoOrange),
                ),
              ),
              child: FoodTag(),
            ),
          );
        });
  }

  // _getLatitude() {
  //   selectedLocation.producer.take(1).listen((result) {
  //     // setState(() {
  //       newLatitude = result.latitude;
  //     // });
  //     print('Selected Location at OrderNow.dart: Lat = $newLatitude');
  //     return newLatitude;
  //   });
  // }
  // _getLongitude() {
  //   selectedLocation.producer.take(1).listen((result) {
  //     // setState(() {
  //       newLongitude = result.longitude;
  //     // });
  //     print('Selected Location at OrderNow.dart: Lng = $newLongitude');
  //     return newLongitude;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomizedMap(
          mode: 0,
          newLatitude: newLatitude,
          newLongitude: newLongitude, 
          selectedlocation: selectedLocation,
        ),
        CustomizedBackButton(),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(14.0),
              margin: EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 6.0),
              height: 130.0,
              decoration: BoxDecoration(
                  color: ColorHelper.dabaoOffWhiteF5,
                  borderRadius: BorderRadius.circular(9.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                    )
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Deliver to...',
                    style: FontHelper.normalTextStyle,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/pin.png',
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      GestureDetector(
                        child: Container(
                          child: Text(
                            _address,
                            style: FontHelper.placeholderTextStyle,
                          ),
                        ),
                        onTap: _handlePressButton,
                      ),
                    ],
                  ),
                  Divider(height: 15.0, indent: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      OutlineButton(
                        highlightedBorderColor: ColorHelper.dabaoOrange,
                        highlightColor: ColorHelper.dabaoOrange,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        color: ColorHelper.dabaoOffWhiteF5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Image.asset('assets/icons/stand.png'),
                            SizedBox(
                              width: 5.0,
                            ),
                            Column(
                              children: <Widget>[
                                Text('Scheduled'),
                                Text('Order'),
                              ],
                            ),
                          ],
                        ),
                        onPressed: () {
                          _selectStartTime();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.symmetric(
                            horizontal: 22.0, vertical: 9.0),
                        color: ColorHelper.dabaoOrange,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('assets/icons/run.png'),
                            SizedBox(
                              width: 5.0,
                            ),
                            Column(
                              children: <Widget>[
                                Text('Order Now'),
                              ],
                            ),
                          ],
                        ),
                        onPressed: () {
                          _showModalSheet();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      // final result = new LatLng(lat, lng);

      // selectedLocation.producer.add(result);
      // selectedLocation.producer.listen((result){
        setState(() {
                  newLatitude = lat;
                  newLongitude = lng;
                });
      // });

      selectedLocationDescription.producer.add(p.description);
      selectedLocationDescription.producer.listen((desc) {
        setState(() {
          _address = desc;
        });
      });
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    SnackBar(content: Text(response.errorMessage));
  }

  Future<void> _handlePressButton() async {
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

    displayPrediction(p);
  }
}
