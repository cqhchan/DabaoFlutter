import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Route/OverlayRoute.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/TimePicker/ScrollableHourPicker.dart';
import 'package:flutterdabao/TimePicker/ScrollableMinutePicker.dart';
import 'package:rxdart/rxdart.dart';

typedef DoubleDateSelectedCallback = Function(DateTime, DateTime);
typedef DateSelectedCallback = Function(DateTime);

Future<T> showTimeCreator<T>({
  @required BuildContext context,
  bool barrierDismissible = false,
  @required DoubleDateSelectedCallback onCompleteCallBack,
  int startTimeBeforeLimitInMins = 60,
  int minsGapBetweenStartAndEndTime = 30,
  DateTime startTime,
  DateTime endTime,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: true)
      .push<T>(CustomOverlayRoute<T>(
    builder: (context) {
      return _TimePickerEditor(
        startTimeBeforeLimitInMins: startTimeBeforeLimitInMins,
        minsGapBetweenStartAndEndTime: minsGapBetweenStartAndEndTime,
        startTime: startTime,
        endTime: endTime,
        onCompleteCallBack: onCompleteCallBack,
      );
    },
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}

Future<T> showOneTimeCreator<T>({
  @required BuildContext context,
  @required String headerTitle,
  @required String subTitle,
  bool barrierDismissible = false,
  @required DateSelectedCallback onCompleteCallback,
  DateTime startTime,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: true)
      .push<T>(CustomOverlayRoute<T>(
    builder: (context) {
      return _OnetimePickerEditor(
        startTime: startTime,
        headerTitle: headerTitle,
        subTitle: subTitle,
        onCompleteCallback: onCompleteCallback,
      );
    },
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}

class _TimePickerEditor extends StatefulWidget {
  final DoubleDateSelectedCallback onCompleteCallBack;
  final DateTime startTime;
  final DateTime endTime;
  final int minsGapBetweenStartAndEndTime;
  final int startTimeBeforeLimitInMins;
  int lastHour;

  _TimePickerEditor({
    Key key,
    @required this.onCompleteCallBack,
    this.startTime,
    this.endTime,
    this.minsGapBetweenStartAndEndTime = 0,
    this.startTimeBeforeLimitInMins = 0,
  }) : super(key: key);
  __TimePickerEditorState createState() => __TimePickerEditorState();
}

class __TimePickerEditorState extends State<_TimePickerEditor>
    with HavingSubscriptionMixin {
  MutableProperty<DateTime> selectedStartDate;
  MutableProperty<DateTime> selectedEndDate;

  DateTime selectedStartDateByCalander;
  DateTime currentTime;
  DateTime startTime;

  HourPicker integerStartHourPicker;
  MinutePicker integerStartMinutePicker;
  LoopingHourPicker integerEndHourPicker;
  MinutePicker integerEndMinutePicker;

  String errorMessage = "";

  void initState() {
    super.initState();
    currentTime = DateTime.now();
    startTime = currentTime.add(Duration(hours: 1));
    selectedStartDateByCalander = currentTime.add(Duration(hours: 1));
    // Copy Start time to prevent unwanted editting
    selectedStartDate = MutableProperty<DateTime>(widget.startTime != null
        ? DateTime.fromMillisecondsSinceEpoch(
            widget.startTime.millisecondsSinceEpoch)
        : startTime);

    // Copy end time to prevent unwanted editting
    selectedEndDate = MutableProperty<DateTime>(widget.endTime != null
        ? DateTime.fromMillisecondsSinceEpoch(
            widget.endTime.millisecondsSinceEpoch)
        : selectedStartDate.value.add(Duration(hours: 1)));

    // if selected StartDate is earlier than end Date, set endDate to StartDate + 1 hr
    subscription.add(selectedStartDate.producer
        .debounce(Duration(milliseconds: 10))
        .listen((startDate) {
      if (startDate.isAfter(selectedEndDate.value)) {
        selectedEndDate.value = selectedEndDate.value.add(Duration(days: 1));
      }

      if (selectedEndDate.value.isAfter(startDate) &&
          selectedEndDate.value.difference(startDate).inHours > 23) {
        selectedEndDate.value = startDate.add(Duration(days: -1));
      }
    }));

    subscription.add(selectedEndDate.producer
        .debounce(Duration(milliseconds: 10))
        .listen((endDate) {
      if (endDate.isBefore(selectedStartDate.value)) {
        selectedEndDate.value = endDate.add(Duration(days: 1));
      }

      if (endDate.isAfter(selectedStartDate.value) &&
          endDate.difference(selectedStartDate.value).inHours > 23) {
        selectedEndDate.value = endDate.add(Duration(days: -1));
      }
    }));
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Align(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 450, maxWidth: 240),
          child: Column(
            children: <Widget>[
              buildHeader(),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    color: Colors.white),
                child: Column(
                  children: <Widget>[
                    buildSizedBox(),
                    buildDateSelector(),
                    buildSizedBox(),
                    buildStartDeliverSelector(),
                    buildSizedBox(),
                    buildTomorrow(),
                    buildSizedBox(),
                    buildEndDeliverSelector(),
                    buildSizedBox(),
                    buildErrorMessage(),
                    buildSizedBox(),
                    buildBottomButton(context)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildClearButton() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.clear),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.dabaoOrange,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          buildClearButton(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Schedule Your Order',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  'Deliver my food between...',
                  style: TextStyle(
                    fontSize: 10,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSizedBox() {
    return SizedBox(
      height: 10,
    );
  }

  Widget buildDateSelector() {
    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'Date:',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        GestureDetector(
          onTap: _selectDate,
          child: _handleDateToString(),
        ),
      ],
    );
  }

  _handleDateToString() {
    return StreamBuilder<DateTime>(
      stream: selectedStartDate.producer,
      builder: (context, snap) {
        if (!snap.hasData || snap.data == null) return Offstage();

        return Text(
          _getDateFormat(snap.data),
          style: FontHelper.semiBold(Colors.black, 20),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  String _getDateFormat(DateTime time) {
    if (DateTimeHelper.isToday(time)) {
      return "Today";
      // if tomorrow
    } else if (DateTimeHelper.isTomorrow(time)) {
      return 'Tomorrow';
    } else {
      return '${time.day}-${time.month}-${time.year}';
    }
  }

  Widget buildStartDeliverSelector() {
    integerStartHourPicker = new HourPicker.hour(
      maxValue: 7 * 24 - 1,
      minValue: selectedStartDateByCalander.hour,
      initialValue: selectedStartDateByCalander.hour +
          (selectedStartDate.value
                      .difference(selectedStartDateByCalander)
                      .inMinutes /
                  60)
              .ceil(),
      onChanged: (value) {
        _handleStartHourChanged(value);
      },
    );

    integerStartMinutePicker = new MinutePicker.minute(
      maxValue: 5,
      minValue: 0,
      initialValue: selectedStartDate.value.minute ~/ 10,
      step: 1,
      onChanged: (value) {
        _handleStartMinuteChanged(value * 10);
      },
    );

    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'Start: ',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        integerStartHourPicker,
        Text(':', style: FontHelper.semiBold(Colors.black, 45)),
        integerStartMinutePicker,
      ],
    );
  }

  _handleStartHourChanged(num hour) {
    selectedStartDate.value = new DateTime(
        selectedStartDateByCalander.year,
        selectedStartDateByCalander.month,
        selectedStartDateByCalander.day,
        selectedStartDateByCalander.hour + hour,
        selectedStartDate.value.minute,
        selectedStartDate.value.second,
        selectedStartDate.value.millisecond);
  }

  _handleStartMinuteChanged(num minute) {
    selectedStartDate.value = new DateTime(
        selectedStartDate.value.year,
        selectedStartDate.value.month,
        selectedStartDate.value.day,
        selectedStartDate.value.hour,
        minute,
        selectedStartDate.value.second,
        selectedStartDate.value.millisecond);
  }

  _handleEndHourChanged(num hour) {
    selectedEndDate.value = new DateTime(
        selectedEndDate.value.year,
        selectedEndDate.value.month,
        selectedEndDate.value.day,
        hour,
        selectedEndDate.value.minute,
        selectedEndDate.value.second,
        selectedEndDate.value.millisecond);
  }

  _handleEndMinuteChanged(num minute) {
    selectedEndDate.value = new DateTime(
        selectedEndDate.value.year,
        selectedEndDate.value.month,
        selectedEndDate.value.day,
        selectedEndDate.value.hour,
        minute,
        selectedEndDate.value.second,
        selectedEndDate.value.millisecond);
  }

  Widget buildTomorrow() {
    return StreamBuilder<bool>(
      stream: Observable.combineLatest2(
          selectedStartDate.producer, selectedEndDate.producer,
          (startDate, endDate) {
        if (DateTimeHelper.sameDay(startDate, endDate)) {
          return true;
        }

        return false;
      }),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData || snapshot.data) return Offstage();

        return Row(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(minHeight: 20, minWidth: 40),
              child: Text(
                'Date:',
                style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
              ),
            ),
            Text(
              _getDateFormat(selectedEndDate.value),
              style: FontHelper.semiBold(Colors.black, 20),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget buildEndDeliverSelector() {
    integerEndHourPicker = new LoopingHourPicker.hour(
      maxValue: 23,
      minValue: 0,
      initialValue: selectedEndDate.value.hour,
      onChanged: (value) {
        _handleEndHourChanged(value);
      },
    );

    integerEndMinutePicker = new MinutePicker.minute(
      maxValue: 5,
      minValue: 0,
      initialValue: selectedEndDate.value.minute ~/ 10,
      step: 1,
      onChanged: (value) {
        _handleEndMinuteChanged(value * 10);
      },
    );

    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'End: ',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        integerEndHourPicker,
        Text(':', style: FontHelper.semiBold(Colors.black, 45)),
        integerEndMinutePicker
      ],
    );
  }

  Widget buildErrorMessage() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Text(
          errorMessage,
          style: FontHelper.semiBold(Colors.red, 12.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildBottomButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FlatButton(
        color: ColorHelper.dabaoOrange,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time),
            Expanded(
              child: Align(
                child: Text(
                  "Confirm",
                  style: FontHelper.semiBold(Colors.black, 14.0),
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          if (selectedStartDate.value.isAfter(DateTime.now()
                  .add(Duration(minutes: widget.startTimeBeforeLimitInMins))) &&
              selectedEndDate.value.isAfter(selectedStartDate.value.add(
                  Duration(minutes: widget.minsGapBetweenStartAndEndTime)))) {
            print('confirmed start: ${selectedStartDate.value}');
            print('confirmed end: ${selectedEndDate.value}');
            Navigator.of(context).pop();
            widget.onCompleteCallBack(
                selectedStartDate.value, selectedEndDate.value);
          } else {
            print('wrong start: ${selectedStartDate.value}');
            print('wrong end: ${selectedEndDate.value}');
            setState(() {
              errorMessage =
                  "Minimim time period is 30 minutes and at least 1 hour from now.";
            });
          }
        },
      ),
    );
  }

  Future _selectDate() async {
    await showDatePicker(
      context: context,
      initialDate: selectedStartDate.value,
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(9999),
    ).then((date) {
      if (date != null) {
        selectedStartDateByCalander = date;
        selectedStartDate.value = DateTime(
            selectedStartDateByCalander.year,
            selectedStartDateByCalander.month,
            selectedStartDateByCalander.day,
            selectedStartDate.value.hour,
            selectedStartDate.value.minute,
            selectedStartDate.value.second);
      }
    });
  }

  ///Round down minute to the nearest ten.
  _handleMinute(int value) {
    if (value < 10 || value == null) {
      return 0;
    } else if (value < 20 && value >= 10) {
      return 10;
    } else if (value < 30 && value >= 20) {
      return 20;
    } else if (value < 40 && value >= 30) {
      return 30;
    } else if (value < 50 && value >= 40) {
      return 40;
    } else if (value < 60 && value >= 50) {
      return 50;
    } else {
      return value;
    }
  }
}

class _OnetimePickerEditor extends StatefulWidget {
  final DateSelectedCallback onCompleteCallback;
  final DateTime startTime;
  final String headerTitle;
  final String subTitle;

  const _OnetimePickerEditor({
    Key key,
    @required this.onCompleteCallback,
    this.startTime,
    this.headerTitle,
    this.subTitle,
  }) : super(key: key);

  __OneTimePickerEditorState createState() => __OneTimePickerEditorState();
}

class __OneTimePickerEditorState extends State<_OnetimePickerEditor> {
  MutableProperty<DateTime> selectedStartDate;
  DateTime _currentStartTime;

  HourPicker integerStartHourPicker;
  MinutePicker integerStartMinutePicker;

  String errorMessage = "";

  void initState() {
    super.initState();

    _currentStartTime = DateTime.now().add(Duration(hours: 1));
    selectedStartDate = MutableProperty(_currentStartTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Align(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 450, maxWidth: 240),
          child: Column(
            children: <Widget>[
              buildHeader(),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    color: Colors.white),
                child: Column(
                  children: <Widget>[
                    buildSizedBox(),
                    buildDateSelector(),
                    buildSizedBox(),
                    buildSizedBox(),
                    buildSizedBox(),
                    buildSizedBox(),
                    buildSizedBox(),
                    buildStartDeliverSelector(),
                    buildSizedBox(),
                    buildSizedBox(),
                    buildSizedBox(),
                    buildSizedBox(),
                    buildSizedBox(),
                    buildErrorMessage(),
                    buildBottomButton(context)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconButton buildClearButton() {
    return IconButton(
      color: Colors.black,
      icon: Icon(Icons.clear),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Container buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.dabaoOrange,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          buildClearButton(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.headerTitle,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  widget.subTitle,
                  style: TextStyle(
                    fontSize: 10,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox buildSizedBox() {
    return SizedBox(
      height: 10,
    );
  }

  Row buildDateSelector() {
    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'Date:',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        GestureDetector(
          // onTap: _selectDate,
          child: _handleDateToString(),
        ),
      ],
    );
  }

  _handleDateToString() {
    return StreamBuilder<DateTime>(
      stream: selectedStartDate.producer,
      builder: (context, snap) {
        if (!snap.hasData || snap.data == null) return Offstage();

        return Text(
          _getDateFormat(snap.data),
          style: FontHelper.semiBold(Colors.black, 20),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  String _getDateFormat(DateTime time) {
    if (DateTimeHelper.isToday(time)) {
      return "Today";
      // if tomorrow
    } else if (DateTimeHelper.isTomorrow(time)) {
      return 'Tomorrow';
    } else {
      return '${time.day}-${time.month}-${time.year}';
    }
  }

  Widget buildStartDeliverSelector() {
    integerStartHourPicker = new HourPicker.hour(
      maxValue: _currentStartTime.hour + 72,
      minValue: _currentStartTime.hour,
      initialValue: selectedStartDate.value.hour,
      onChanged: (value) {
        _handleHour(value);
      },
    );

    integerStartMinutePicker = new MinutePicker.minute(
      maxValue: 5,
      minValue: 0,
      initialValue: selectedStartDate.value.minute ~/ 10,
      step: 1,
      onChanged: (value) {
        _handleMinuteChanged(value * 10);
      },
    );

    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'Start: ',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        integerStartHourPicker,
        Text(':', style: FontHelper.semiBold(Colors.black, 45)),
        integerStartMinutePicker,
      ],
    );
  }

  //Minute change is dependant on the hour change.
  _handleHour(num hour) {
    DateTime newDate = new DateTime(
        _currentStartTime.year,
        _currentStartTime.month,
        _currentStartTime.day,
        _currentStartTime.hour + hour,
        selectedStartDate.value.minute,
        selectedStartDate.value.second,
        selectedStartDate.value.millisecond);

    selectedStartDate.value = newDate;
  }

  _handleMinuteChanged(num minute) {
    selectedStartDate.value = new DateTime(
        selectedStartDate.value.year,
        selectedStartDate.value.month,
        selectedStartDate.value.day,
        selectedStartDate.value.hour,
        minute,
        selectedStartDate.value.second,
        selectedStartDate.value.millisecond);
  }

  Widget buildErrorMessage() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Text(
          errorMessage,
          style: FontHelper.semiBold(Colors.red, 12.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget buildBottomButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FlatButton(
        color: ColorHelper.dabaoOrange,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time),
            Expanded(
              child: Align(
                child: Text(
                  "Confirm",
                  style: FontHelper.semiBold(Colors.black, 14.0),
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          if (selectedStartDate.value
              .isAfter(DateTime.now().subtract(Duration(minutes: 10)))) {
            print('confirmed start: $selectedStartDate.value');
            Navigator.of(context).pop();
            widget.onCompleteCallback(selectedStartDate.value);
          } else {
            print('wrong start: $selectedStartDate.value');
            setState(() {
              errorMessage = "At least from time now";
            });
          }
        },
      ),
    );
  }

  // Future _selectDate() async {
  //   await showDatePicker(
  //     context: context,
  //     initialDate: selectedStartDate.value,
  //     firstDate: DateTime(
  //         DateTime.now().year, DateTime.now().month, DateTime.now().day),
  //     lastDate: DateTime(2100),
  //   ).then((date) {
  //     if (date != null) {
  //       setState(() {
  //         _currentStartTime = DateTime(
  //           date.year,
  //           date.month,
  //           date.day,
  //         );

  //         selectedStartDate.value = DateTime(
  //             _currentStartTime.year,
  //             _currentStartTime.month,
  //             _currentStartTime.day,
  //             selectedStartDate.value.hour +1,
  //             selectedStartDate.value.minute,
  //             selectedStartDate.value.second);
  //       });
  //     }
  //   });
  // }
}
