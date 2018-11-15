import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/Slot.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

typedef tapEvent = void Function(DateTime, DateTime);

class TimeSlotPicker extends StatefulWidget {
  final DateTime date;
  final ShapeBorder slotBorder;
  final TextStyle textStyle;
  final tapEvent onTap;
  TimeSlotPicker(
      {Key key,
      this.date,
      this.slotBorder,
      this.textStyle,
      @required this.onTap})
      : super(key: key);
  @override
  _TimeSlotPickerState createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  DateTime _currentDate = new DateTime.now();
  List<Slot> _timeSlots = [];
  bool pressed = false;

  _handleColor(bool _pressed) {
    if (_pressed == true) {
      return kDateTimePicked;
    } 
    if (_pressed == false) {
      return kDateTimeUnpicked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      color: kDateTimeContainer,
      padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: _timeSlots.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: FlatButton(
              color: _handleColor(_timeSlots[index].pressed),
              // pressed ? kDateTimePicked : kDateTimeUnpicked
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              padding: EdgeInsets.all(5.0),
              child: Text(
                _timeSlots[index].slotString,
                style: TextStyle(),
              ),
              onPressed: () {
                // widget.onTap(
                //     _timeSlots[index].startTime, _timeSlots[index].endTime);
                setState(() {
                  if (_timeSlots[index].pressed == false) {
                    for (var i = 0; i < _timeSlots.length; i++) {
                      _timeSlots[i].pressed = false;
                    }
                    _timeSlots[index].pressed = true;
                  } else {
                    _timeSlots[index].pressed = false;
                  }
                });
              },
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

    this._timeSlots = _createTimeList(_currentDate);
  }

  List<Slot> _createTimeList(DateTime date) {
    List<Slot> slots = [];
    DateTime currentStartTime = date;
    const numOfRange = 24;
    for (var i = 0; i < numOfRange; i++) {
      Slot slot = new Slot();
      slot.startTime = currentStartTime;
      slot.endTime = currentStartTime
          .add(Duration(hours: 1))
          .subtract(Duration(seconds: 1));
      slot.slotString = _24HourTo12HourString(slot.startTime) +
          " - " +
          _24HourTo12HourString(slot.endTime);
      currentStartTime = currentStartTime.add(Duration(hours: 1));

      if (DateTime.now().millisecondsSinceEpoch <
          slot.startTime.millisecondsSinceEpoch) {
        slots.add(slot);
      }

      // if (slot.endTime.hour == 23 && slot.endTime.minute == 59) break;
    }
    return slots;
  }

  String _24HourTo12HourString(DateTime time) {
    if (time.hour == 0) {
      String minute = time.minute.toString().length < 2
          ? "0" + time.minute.toString()
          : time.minute.toString();
      return "12:$minute";
    } else if (time.hour < 12) {
      String hour = time.hour.toString().length < 2
          ? "0" + time.hour.toString()
          : time.hour.toString();
      String minute = time.minute.toString().length < 2
          ? "0" + time.minute.toString()
          : time.minute.toString();
      return "$hour:$minute";
    } else if (time.hour == 12) {
      String minute = time.minute.toString().length < 2
          ? "0" + time.minute.toString()
          : time.minute.toString();
      return "12:$minute";
    } else {
      String hour = (time.hour - 12).toString().length < 2
          ? "0" + (time.hour - 12).toString()
          : (time.hour - 12).toString();
      String minute = time.minute.toString().length < 2
          ? "0" + time.minute.toString()
          : time.minute.toString();
      return "$hour:$minute";
    }
  }
}
