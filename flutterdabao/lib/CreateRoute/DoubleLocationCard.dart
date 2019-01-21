import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMapPlaces.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Holder/RouteHolder.dart';
import 'package:flutterdabao/TimePicker/TimePickerEditor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rxdart/rxdart.dart';

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
                  height: 15.0,
                ),
                Text(
                  "I\'m buying from..",
                  style: FontHelper.semiBold(ColorHelper.dabaoOffGrey70, 14),
                ),
                SizedBox(
                  height: 10.0,
                ),
                buildSelectedlocationWidget(
                    true,
                    widget.holder.startDeliveryLocation,
                    widget.holder.startDeliveryLocationDescription,
                    "assets/icons/blue_marker.png",
                    "Enter start destination"),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 8.0),
                      height: 20,
                      width: 1,
                      child:
                          Image.asset("assets/icons/dotted_line_straight.png"),
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
                    "Enter Delivery Destination"),
                StreamBuilder<bool>(
                  stream: Observable.combineLatest2(
                      widget.holder.startDeliveryLocation.producer,
                      widget.holder.endDeliveryLocation.producer,
                      (startLocation, endLocation) =>
                          startLocation != null && endLocation != null),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data)
                      return Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: _createRoute(),
                      );
                    else
                      return Container();
                  },
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
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 30,
                width: 30,
                margin: EdgeInsets.only(left: 15),
                child: Image.asset(
                  'assets/icons/bike.png',
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: Text(
                'Proceed',
                style: FontHelper.bold(Colors.black, 16.0),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        onPressed: () {
          if (widget.holder.startDeliveryLocation.value != null &&
              widget.holder.endDeliveryLocation.value != null)
            showOneTimeCreator(
                minutes: 1,
                context: context,
                startTime: widget.holder.deliveryTime.value,
                headerTitle: "Select Arrival Time",
                onCompleteCallback: (DateTime selectedTime) {
                  widget.holder.deliveryTime.value = selectedTime;
                  widget.showOverlayCallback();
                },
                subTitle: "I will be arriving at...");
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
          widget.focusOnStart.value = focusOnStart;
          _handlePressButton(locationProperty, locationDescriptionProperty);
        },
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: Text(
        'Let\'s create your route!',
        style: FontHelper.semiBold16(ColorHelper.dabaoOffBlack4A),
      ),
    );
  }

  Future<void> _handlePressButton(MutableProperty<LatLng> locationProperty,
      MutableProperty<String> locationDescriptionProperty) async {
    await handlePressButton(context, (location, description) {
      locationProperty.producer.add(location);
      locationDescriptionProperty.producer.add(description);
    }, locationDescriptionProperty.value);
  }

  void onError(PlacesAutocompleteResponse response) {
    SnackBar(content: Text(response.errorMessage));
  }
}
