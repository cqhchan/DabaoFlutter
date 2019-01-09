import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:flutterdabao/TimePicker/ScrollableHourPicker.dart';
import 'package:flutterdabao/TimePicker/ScrollableMinutePicker.dart';

class CounterOfferOverlay extends StatefulWidget {
  final Order order;
  final DabaoRoute.Route route;

  const CounterOfferOverlay({Key key, @required this.order, this.route})
      : super(key: key);
  _CounterOfferOverlayState createState() => _CounterOfferOverlayState();
}

class _CounterOfferOverlayState extends State<CounterOfferOverlay>
    with HavingSubscriptionMixin {
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  //selected date on press
  MutableProperty<DateTime> selectedDate;

  HourPicker hourPicker;
  MinutePicker minutePicker;

  DateTime startTime;
  DateTime endTime;

  MutableProperty<double> _sliderSelector = MutableProperty<double>(null);

  @override
  void initState() {
    super.initState();
    listOfOrderItems = widget.order.orderItem;

    DateTime currentTime = DateTime.now();

    subscription.add(widget.order.mode.listen((mode) {
      switch (mode) {
        case OrderMode.asap:
          setState(() {
            endTime = widget.order.endDeliveryTime.value == null
                ? currentTime.add(Duration(minutes: 90))
                : widget.order.endDeliveryTime.value;
            startTime = currentTime.isAfter(endTime) ? endTime : currentTime;
          });

          break;
        case OrderMode.scheduled:
          setState(() {
            endTime = widget.order.endDeliveryTime.value;
            startTime = widget.order.startDeliveryTime.value;
          });

          break;
      }

      //Copy to prevent editting
      selectedDate = MutableProperty(DateTime.fromMillisecondsSinceEpoch(
          startTime.millisecondsSinceEpoch));
    }));

    subscription.add(_sliderSelector
        .bindTo(widget.order.deliveryFee.where((fee) => fee != null).take(1)));
  }

  //Minute change is dependant on the hour change.
  _handleHour(num hour) {
    DateTime newDate = new DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
        startTime.hour + hour,
        selectedDate.value.minute,
        selectedDate.value.second,
        selectedDate.value.millisecond);

    selectedDate.value = newDate;
  }

  _handleMinuteChanged(num minute) {
    selectedDate.value = new DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        selectedDate.value.hour,
        minute,
        selectedDate.value.second,
        selectedDate.value.millisecond);
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildHeader(),
              Line(
                margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
              ),
              _buildDeliveryPeriod(widget.order),
              _buildArrivalTime(widget.order),
              SizedBox(
                height: 15,
              ),
              _buildLocationDescription(widget.order),
              Line(
                margin: EdgeInsets.only(top: 20.0, bottom: 5.0),
              ),
              _buildCurrentFee(),
              Line(
                margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
              ),
              _buildSlider(),
              SizedBox(
                height: 10,
              ),
              _buildOffer(),
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
                      child: _buildConfirmButton(widget.order),
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

  Row _buildLocationDescription(Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArrivalTime(Order order) {
    if (startTime == null || endTime == null) {
      return Text("ERROR");
    }
    print("testing Max : " +
        (startTime.hour + (endTime.difference(startTime).inMinutes / 60).ceil())
            .toString());
    print("testing init : " +
        (startTime.hour + selectedDate.value.difference(startTime).inHours)
            .toString());

    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'I can arrive by: ',
            style: FontHelper.regular14Black,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        HourPicker.hour(
          maxValue: startTime.hour +
              (endTime.difference(startTime).inMinutes / 60).ceil(),
          minValue: startTime.hour,
          initialValue:
              startTime.hour + selectedDate.value.difference(startTime).inHours,
          onChanged: (value) {
            print(value);
            _handleHour(value);
          },
        ),
        Text(':', style: FontHelper.robotoRegular50Black),
        MinutePicker.minute(
          maxValue: 5,
          minValue: 0,
          initialValue: selectedDate.value.minute ~/ 10,
          step: 1,
          onChanged: (value) {
            _handleMinuteChanged(value * 10);
          },
        ),
      ],
    );
  }

  Row _buildDeliveryPeriod(Order order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        (startTime.day == DateTime.now().day &&
                startTime.month == DateTime.now().month &&
                startTime.year == DateTime.now().year)
            ? Text(
                'Today, ' + DateTimeHelper.convertDateTimeToAMPM(startTime),
                style: FontHelper.semiBold14Black,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                DateTimeHelper.convertDateTimeToDate(startTime) +
                    ', ' +
                    DateTimeHelper.convertDateTimeToAMPM(startTime),
                style: FontHelper.semiBold14Black,
                overflow: TextOverflow.ellipsis,
              ),
        Container(
            child: Text(
          " - " + DateTimeHelper.convertDateTimeToAMPM(endTime),
          style: FontHelper.semiBold14Black,
          overflow: TextOverflow.ellipsis,
        )),
      ],
    );
  }

  Widget _buildHeader() {
    return Text(
      'Counter-Offer Deliver Fee',
      style: FontHelper.semiBold16Black,
    );
  }

  Widget _buildCurrentFee() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: Text(
            'Current Delivery Fee',
            style: FontHelper.bold12Black,
          ),
        ),
        Expanded(
          child: StreamBuilder<double>(
            stream: widget.order.deliveryFee,
            builder: (context, snap) {
              if (!snap.hasData) return Offstage();
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    snap.hasData
                        ? StringHelper.doubleToPriceString(snap.data)
                        : "Error",
                    style: FontHelper.regular12Black,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(
                    width: 2.0,
                  ),
                  Image.asset('assets/icons/question_mark.png'),
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildSlider() {
    return Column(
      children: <Widget>[
        StreamBuilder<double>(
            stream: _sliderSelector.producer,
            builder: (context, snap) {
              if (!snap.hasData || snap.data == null) return Offstage();

              return Container(
                color: Color(0xFFF3F3F3),
                child: Slider(
                  activeColor: Color(0xFFBCE0FD),
                  inactiveColor: Colors.white,
                  divisions: 6,
                  max: 6.0,
                  min: 0.0,
                  value: 3.5,
                  onChanged: (data) {
                    _sliderSelector.value = data;
                  },
                ),
              );
            }),
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(1.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(2.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(2.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(3.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(3.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(4.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(4.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
          ],
        )
      ],
    );
  }

  Widget _buildOffer() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: Text(
            'Your Offer',
            style: FontHelper.bold12Black,
          ),
        ),
        StreamBuilder<double>(
          stream: _sliderSelector.producer,
          builder: (context, snap) {
            if (!snap.hasData || snap.data == null) return Offstage();
            return Expanded(
                child: Text(
              StringHelper.doubleToPriceString(snap.data),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.right,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton(Order order) {
    return StreamBuilder(
      stream: order.mode,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        switch (snap.data) {
          case OrderMode.asap:
            return RaisedButton(
              elevation: 12,
              color: Color(0xFF959DAD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Center(
                child: Text(
                  "Confirm",
                  style: FontHelper.semiBold14White,
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
