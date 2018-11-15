import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/Slot.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

typedef tapEvent = void Function(DateTime, DateTime);

class DateSlotPicker extends StatefulWidget {
  final DateTime date;
  final ShapeBorder slotBorder;
  final TextStyle textStyle;
  final tapEvent onTap;
  DateSlotPicker(
      {Key key,
      this.date,
      this.slotBorder,
      this.textStyle,
      @required this.onTap})
      : super(key: key);
  @override
  _TimeSlotPickerState createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<DateSlotPicker> {
  DateTime _currentDate = new DateTime.now();
  List<Slot> _dateSlots = [];
  List<Slot> _daySlots = [];
  // bool pressed = false;

  _handleColor(DateTime _inputDate) {
    if (_inputDate.millisecondsSinceEpoch <
        _currentDate.millisecondsSinceEpoch) {
      return kDateTimeUnavailable;
    }
    if (_inputDate.millisecondsSinceEpoch ==
        _currentDate.millisecondsSinceEpoch) {
      return kDateTimePicked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      color: kDateTimeContainer,
      padding: EdgeInsets.all(6.0),
      child: new ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: _dateSlots.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 60.0,
            child: FlatButton(
              shape: CircleBorder(),
              padding: EdgeInsets.all(2.0),
              color: _handleColor(_daySlots[index].startDate),
              child: Column(
                children: <Widget>[
                  Text(
                    _daySlots[index].slotString,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _dateSlots[index].slotString,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              onPressed: () {},
              // () {
              //   widget.onTap(
              //       _dateSlots[index].startDate, _dateSlots[index].endTime);
              //   // setState(() {
              //   //   pressed = !pressed;
              //   // });
              // },
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.date != null) _currentDate = widget.date;
    _currentDate =
        new DateTime(_currentDate.year, _currentDate.month, _currentDate.day);

    this._dateSlots = _createDateList(_currentDate);
    this._daySlots = _createDaysList(_currentDate);
  }

  List<Slot> _createDaysList(DateTime date) {
    List<Slot> slots = [];
    DateTime currentStartDate = date;
    const numOfDays = 7;
    for (var i = 0; i < numOfDays; i++) {
      Slot slot = new Slot();

      slot.startDate = currentStartDate.subtract(Duration(days: 2));
      slot.slotString = _weekdayConversion(slot.startDate.weekday.toString());
      currentStartDate = currentStartDate.add(Duration(days: 1));
      slots.add(slot);
    }
    return slots;
  }

  List<Slot> _createDateList(DateTime date) {
    List<Slot> slots = [];
    DateTime currentStartDate = date;
    const numOfDays = 7;
    for (var i = 0; i < numOfDays; i++) {
      Slot slot = new Slot();

      slot.startDate = currentStartDate.subtract(Duration(days: 2));
      slot.slotString = slot.startDate.day.toString();
      currentStartDate = currentStartDate.add(Duration(days: 1));
      slots.add(slot);
    }
    return slots;
  }

  _weekdayConversion(String days) {
    switch (days) {
      case "1":
        return "M";
        break;
      case "2":
        return "T";
        break;
      case "3":
        return "W";
        break;
      case "4":
        return "T";
        break;
      case "5":
        return "F";
        break;
      case "6":
        return "S";
        break;
      case "7":
        return "S";
        break;
    }
  }
}
