import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMapPlaces.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/TimePicker/TimePickerEditor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends StatefulWidget {
  final OrderHolder holder;

  final VoidCallback showOverlayCallback;
  const LocationCard({
    Key key,
    @required this.holder,
    @required this.showOverlayCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LocationCardState();
  }
}

class LocationCardState extends State<LocationCard> with HavingGoogleMapPlaces {
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
                StreamBuilder<LatLng>(
                  stream: widget.holder.deliveryLocation.producer,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null)
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          _scheduleOrder(),
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(minWidth: 10.0, maxWidth: 20.0),
                          ),
                          _orderNow(),
                        ],
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

  Expanded _orderNow() {
    return Expanded(
      child: Container(
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
              Image.asset('assets/icons/run.png'),
              SizedBox(
                width: 5.0,
              ),
              Flexible(
                child: Center(
                  child: Text(
                    'Order Now',
                    style: FontHelper.bold(Colors.black, 16.0),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 15.0, maxWidth: 22.0),
              ),
            ],
          ),
          onPressed: () {
            widget.holder.mode.value = OrderMode.asap;
            widget.showOverlayCallback();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        height: 55.0,
      ),
    );
  }

  Widget _scheduleOrder() {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: 55.0, minHeight: 55.0, minWidth: 90.0, maxWidth: 105.0),
      // height: 55.0,
      // width: 105.0,
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
            FittedBox(
              child: Text(
                'Scheduled\nOrder',
                textAlign: TextAlign.center,
                style: FontHelper.bold(Colors.black, 12.0),
              ),
            ),
          ],
        ),
        onPressed: () {
          showTimeCreator(
            startTime: widget.holder.startDeliveryTime.value,
            endTime: widget.holder.endDeliveryTime.value,
            context: context,
            onCompleteCallBack: (DateTime start, DateTime end) {
              widget.holder.startDeliveryTime.value = start;
              widget.holder.endDeliveryTime.value = end;
              widget.holder.mode.value = OrderMode.scheduled;
              widget.showOverlayCallback();
            },
          );
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
        Expanded(child: buildSelectedLocationTextWidget()),
      ],
    );
  }

  Widget buildSelectedLocationTextWidget() {
    return Container(
      child: GestureDetector(
        child: StreamBuilder<String>(
          stream: widget.holder.deliveryLocationDescription.producer,
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
                overflow: TextOverflow.ellipsis,
              );
            }
          },
        ),
        onTap: () async {
          await handlePressButton(
              context,
              widget.holder.deliveryLocation,
              widget.holder.deliveryLocationDescription,
              widget.holder.deliveryLocationDescription.value);
        },
      ),
    );
  }

  Text buildHeader() {
    return Text(
      'Deliver to...',
      style: FontHelper.semiBold16(ColorHelper.dabaoOffBlack4A),
    );
  }
}
