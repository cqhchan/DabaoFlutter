import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutterdabao/CustomWidget/CreateOrangeButton.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMapPlaces.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class LocationCard extends StatefulWidget {
  final MutableProperty<String> selectedLocationDescription;
  final MutableProperty<LatLng> selectedLocation;

  const LocationCard({
    Key key,
    @required this.selectedLocationDescription,
    @required this.selectedLocation,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LocationCardState();
  }
}

class LocationCardState extends State<LocationCard> with HavingGoogleMapPlaces {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          alignment: Alignment(0.0, -1.0),
          padding: EdgeInsets.fromLTRB(23.0, 15.0, 23.0, 15.0),
          margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 35.0),
          height: 160.0,
          decoration: BoxDecoration(
              color: ColorHelper.dabaoOffWhiteF5,
              borderRadius: BorderRadius.circular(9.0),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0.0, 1.0),
                  color: Colors.grey,
                  blurRadius: 5.0,
                )
              ]),
          child: Column(
            children: <Widget>[
              Text(
                'Deliver to...',
                style: FontHelper.normalTextStyle,
                textAlign: TextAlign.start,
              ),
              Row(
                children: <Widget>[
                  Image.asset(
                    'assets/icons/pin.png',
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: StreamBuilder<String>(
                        stream: widget.selectedLocationDescription.producer,
                        builder: (context, addressSnap) {
                          if (addressSnap.connectionState ==
                                  ConnectionState.waiting ||
                              !addressSnap.hasData) {
                            return Text(
                              "Select Location",
                              style: FontHelper.semiBold(
                                  ColorHelper.dabaoOffBlack9B, 14.0),
                            );
                          } else {
                            return Text(
                              addressSnap.data,
                              style: FontHelper.semiBold(Colors.black, 14.0),
                            );
                          }
                        },
                      ),
                      onTap: _handlePressButton,
                    ),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
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
                  CreateOrangeButton(
                      imageAsset: 'assets/icons/run.png', text: 'Order Now'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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

    if (p != null) {
      LatLng newLocation = await getLatLng(p);
      widget.selectedLocation.producer.add(newLocation);
      widget.selectedLocationDescription.producer.add(p.description);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    SnackBar(content: Text(response.errorMessage));
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
}
