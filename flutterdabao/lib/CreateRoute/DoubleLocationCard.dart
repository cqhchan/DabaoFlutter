import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMapPlaces.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/RouteHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/TimePicker/TimePickerEditor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class DoubleLocationCard extends StatefulWidget {
  final RouteHolder holder;
  final MutableProperty<bool> focusOnStart;
  final VoidCallback showOverlayCallback;
  const DoubleLocationCard({
    Key key,
    @required this.holder,
    @required this.showOverlayCallback,
    @required this.focusOnStart,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DoubleLocationCardState();
  }
}

class _DoubleLocationCardState extends State<DoubleLocationCard>
    with HavingGoogleMapPlaces {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Alignment(0.0, -1.0),
            padding: EdgeInsets.fromLTRB(23.0, 15.0, 23.0, 20.0),
            margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 35.0),
            // height: 160.0,
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
                buildSelectedlocationWidget(
                    true,
                    widget.holder.startDeliveryLocation,
                    widget.holder.startDeliveryLocationDescription,
                    "assets/icons/blue_marker.png",
                    "Enter your location"),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 8.0),
                      height: 20,
                      width: 1,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: Line(
                        margin: EdgeInsets.fromLTRB(20.0, 15.0, 0.0, 15.0),
                      ),
                    ),
                  ],
                ),
                buildSelectedlocationWidget(
                    false,
                    widget.holder.endDeliveryLocation,
                    widget.holder.endDeliveryLocationDescription,
                    "assets/icons/red_marker_icon.png",
                    "Enter Destination"),
                Container(
                  margin: EdgeInsets.only(top: 30.0),
                  child: _createRoute(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createRoute() {
    return Container(
      child: RaisedButton(
        elevation: 0.0,
        highlightElevation: 0.0,
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 9.0),
        color: ColorHelper.dabaoOrange,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 15.0, maxWidth: 22.0),
            ),
            Image.asset(
              'assets/icons/bike.png',
              color: Colors.black,
            ),
            Flexible(
              child: Center(
                child: Text(
                  'Set Route',
                  style: FontHelper.bold(Colors.black, 16.0),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 30.0, maxWidth: 40.0),
            ),
          ],
        ),
        onPressed: () {
          showOneTimeCreator(
              context: context,
              startTime: widget.holder.deliveryTime.value,
              headerTitle: "Select Delivery Time",
              onCompleteCallback: (DateTime selectedTime) {
                print("testing 12 ");
                widget.holder.deliveryTime.value = selectedTime;
                widget.showOverlayCallback();
              },
              subTitle: "I will be delivering at...");
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      height: 55.0,
    );
  }

  Row buildSelectedlocationWidget(
      bool focusOnStart,
      MutableProperty<LatLng> locationProperty,
      MutableProperty<String> locationDescriptionProperty,
      String imagePath,
      String placeHolderText) {
    return Row(
      children: <Widget>[
        Image.asset(
          imagePath,
          fit: BoxFit.fitWidth,
          width: 18.0,
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
            child: buildSelectedLocationTextWidget(
                focusOnStart,
                locationProperty,
                locationDescriptionProperty,
                placeHolderText)),
      ],
    );
  }

  Widget buildSelectedLocationTextWidget(
      bool focusOnStart,
      MutableProperty<LatLng> locationProperty,
      MutableProperty<String> locationDescriptionProperty,
      String placeHolderText) {
    return Container(
      child: GestureDetector(
        child: StreamBuilder<String>(
          stream: locationDescriptionProperty.producer,
          builder: (context, addressSnap) {
            if (addressSnap.connectionState == ConnectionState.waiting ||
                !addressSnap.hasData) {
              return Text(
                placeHolderText,
                style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
              );
            } else {
              return Text(
                addressSnap.data,
                style: FontHelper.semiBold(Colors.black, 14.0),
                overflow: TextOverflow.ellipsis,
              );
            }
          },
        ),
        onTap: () {
          _handlePressButton(
              focusOnStart, locationProperty, locationDescriptionProperty);
        },
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: Text(
        'Let\'s create your route!',
        style: FontHelper.semiBold16(ColorHelper.dabaoOffBlack4A),
      ),
    );
  }

  Future<void> _handlePressButton(
      bool focusOnStart,
      MutableProperty<LatLng> locationProperty,
      MutableProperty<String> locationDescriptionProperty) async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "sg")],
    );

    if (p != null) {
      LatLng newLocation = await getLatLng(p);
      locationProperty.value = newLocation;
      locationDescriptionProperty.value = p.description;
      widget.focusOnStart.value = focusOnStart;
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    SnackBar(content: Text(response.errorMessage));
  }
}
