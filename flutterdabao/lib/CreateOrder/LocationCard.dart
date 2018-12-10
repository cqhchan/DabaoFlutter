import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
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
          padding: EdgeInsets.fromLTRB(23.0, 15.0, 23.0, 0.0),
          margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 35.0),
          height:160.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0.0, 1.0),
                  color: Colors.grey,
                  blurRadius: 5.0,
                )
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildHeader(),
              SizedBox(
                height: 10.0,
              ),
              buildSelectedlocationWidget(),
              Line(
                margin: EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Expanded(child: Container(color: Colors.black,child: Text("t"),),),
                  _scheduleOrder(),
                  SizedBox(
                    width: 20.0,
                  ),
                  _orderNow(),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Expanded _orderNow() {
    return Expanded(
      child: Container(
        child: RaisedButton(
          elevation: 0.0,
          highlightElevation: 0.0,
          padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 9.0),
          color: ColorHelper.dabaoOrange,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset('assets/icons/run.png'),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Center(
                  child: Text('Order Now', style: FontHelper.bold(Colors.black, 16.0),textAlign: TextAlign.start,),
                ),
              ),
            ],
          ),
          onPressed: () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        height: 55.0,
      ),
    );
  }

  Container _scheduleOrder() {
    return Container(
      height: 55.0,
      width: 105.0,
      child: RaisedButton(
        elevation: 0.0,
        highlightElevation: 0.0,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset('assets/icons/stand.png'),
            SizedBox(
              width: 5.0,
            ),
            Text(
              'Scheduled\nOrder',
              textAlign: TextAlign.center,
              style: FontHelper.bold(Colors.black, 12.0),
            ),
          ],
        ),
        onPressed: () {
          _selectStartTime();
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: ColorHelper.dabaoOrange)),
      ),
    );
  }

  Row buildSelectedlocationWidget() {
    return Row(
      children: <Widget>[
        Image.asset(
          'assets/icons/pin.png',
          fit: BoxFit.fill,
          width: 18.0,
          height: 18.0,
        ),
        SizedBox(
          width: 10.0,
        ),
        buildSelectedLocationTextWidget(),
      ],
    );
  }

  GestureDetector buildSelectedLocationTextWidget() {
    return GestureDetector(
      child: Container(
        child: StreamBuilder<String>(
          stream: widget.selectedLocationDescription.producer,
          builder: (context, addressSnap) {
            if (addressSnap.connectionState == ConnectionState.waiting ||
                !addressSnap.hasData) {
              return Text(
                "Select Location",
                style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
              );
            } else {
              return Text(
                addressSnap.data,
                style: FontHelper.semiBold(Colors.black, 14.0),
              );
            }
          },
        ),
      ),
      onTap: _handlePressButton,
    );
  }

  Text buildHeader() {
    return Text(
      'Deliver to...',
      style: FontHelper.semiBold16(ColorHelper.dabaoOffBlack4A),
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
