import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/TimePicker/ScrollableHourPicker.dart';
import 'package:flutterdabao/TimePicker/ScrollableMinutePicker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;

class CompletedOverlay extends StatefulWidget {
  final Order order;
  final DabaoRoute.Route route;

  const CompletedOverlay({Key key, @required this.order, this.route})
      : super(key: key);
  _CompletedOverlayState createState() => _CompletedOverlayState();
}

class _CompletedOverlayState extends State<CompletedOverlay> {
  DateTime isToday;

  HourPicker integerScheduledHourPicker;
  MinutePicker integerScheduledMinutePicker;
  HourPicker integerASAPHourPicker;
  MinutePicker integerASAPMinutePicker;

  int _scheduledInitialHour;
  int _scheduledInitialMinute;
  int _scheduledMaximumMinute;
  int _scheduledMinimumMinute;
  int _scheduledMaximumHour;
  int _scheduledMinimumHour;

  int _asapInitialHour;
  int _asapInitialMinute;
  int _asapMaximumMinute;
  int _asapMinimumMinute;
  int _asapMaximumHour;
  int _asapMinimumHour;

  String selectedDay = 'Today';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isToday = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildHeader(widget.order),
              SizedBox(
                height: 10,
              ),
              _buildLocationDescription(widget.order),
              SizedBox(
                height: 10,
              ),
              Flex(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                verticalDirection: VerticalDirection.up,
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildBackButton(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildPickUpButton(widget.order),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Row _buildDeliveryPeriod(Order order) {
    return Row(
      children: <Widget>[
        StreamBuilder<DateTime>(
          stream: order.startDeliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            if (snap.data.day == DateTime.now().day &&
                snap.data.month == DateTime.now().month &&
                snap.data.year == DateTime.now().year) {
              return Container(
                child: Text(
                  snap.hasData ? 'Today' : "Error",
                  style: FontHelper.semiBoldgrey14TextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            } else {
              return Container(
                child: Text(
                  snap.hasData
                      ? 'For ' +
                          DateTimeHelper.convertDateTimeToDate(snap.data) +
                          ', ' +
                          DateTimeHelper.convertDateTimeToAMPM(snap.data)
                      : "Error",
                  style: FontHelper.semiBoldgrey14TextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
          },
        ),
        StreamBuilder<DateTime>(
          stream: order.endDeliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            return Material(
              child: Text(
                snap.hasData
                    ? ' - ' + DateTimeHelper.convertDateTimeToAMPM(snap.data)
                    : '',
                style: FontHelper.regular14Black,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
    );
  }

  Flex _buildHeader(Order order) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<String>(
                stream: widget.order.foodTag,
                builder: (context, snap) {
                  if (!snap.hasData) return Offstage();
                  return Text(
                    StringHelper.upperCaseWords(snap.data),
                    style: FontHelper.semiBold16Black,
                  );
                },
              ),
              _buildDeliveryPeriod(order),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StreamBuilder<double>(
                stream: widget.order.deliveryFee,
                builder: (context, snap) {
                  if (!snap.hasData) return Offstage();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      StringHelper.doubleToPriceString(
                        snap.data,
                      ),
                      style: FontHelper.bold14Black,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
              StreamBuilder<List<OrderItem>>(
                stream: order.orderItems,
                builder: (context, snap) {
                  if (!snap.hasData) return Offstage();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      snap.hasData ? '${snap.data.length} Item(s)' : "Error",
                      style: FontHelper.medium14TextStyle,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row _buildLocationDescription(Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            right: 5,
          ),
          child: Container(
            height: 30,
            child: Image.asset("assets/icons/red_marker_icon.png"),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<String>(
              stream: order.deliveryLocationDescription,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 180),
                  child: Text(
                    snap.hasData ? '''${snap.data}''' : "Error",
                    style: FontHelper.regular14Black,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickUpButton(Order order) {
    return StreamBuilder(
      stream: order.mode,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        switch (snap.data) {
          case OrderMode.asap:
            return RaisedButton(
              elevation: 12,
              color: ColorHelper.dabaoOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Center(
                child: Text(
                  "Complete",
                  style: FontHelper.semiBold14Black,
                ),
              ),
              onPressed: () async {
                //TODO: blur this widget
              },
            );
          case OrderMode.scheduled:
            return RaisedButton(
              elevation: 12,
              color: ColorHelper.dabaoOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  "Complete",
                  style: FontHelper.semiBold14White,
                ),
              ),
              onPressed: () async {
                //TODO: blur this widget
              },
            );
            break;
          default:
            return Offstage();
        }
      },
    );
  }

  Widget _buildBackButton() {
    return RaisedButton(
      elevation: 12,
      color: ColorHelper.dabaoOffWhiteF5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Text(
          "Back",
          style: FontHelper.semiBold14Black,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}