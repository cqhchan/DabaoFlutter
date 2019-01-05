import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Route/OverlayRoute.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/TimePicker/ScrollableHourPicker.dart';
import 'package:flutterdabao/TimePicker/ScrollableMinutePicker.dart';

typedef DoubleDateSelectedCallback = Function(DateTime, DateTime);
typedef DateSelectedCallback = Function(DateTime);

Future<T> showTimeCreator<T>({
  @required BuildContext context,
  bool barrierDismissible = false,
  @required DoubleDateSelectedCallback onCompleteCallBack,
  DateTime startTime,
  DateTime endTime,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: true)
      .push<T>(CustomOverlayRoute<T>(
    builder: (context) {
      return _TimePickerEditor(
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
  final startTime;
  final endTime;

  const _TimePickerEditor({
    Key key,
    @required this.onCompleteCallBack,
    this.startTime,
    this.endTime,
  }) : super(key: key);
  __TimePickerEditorState createState() => __TimePickerEditorState();
}

class __TimePickerEditorState extends State<_TimePickerEditor> {
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  DateTime _currentStartTime = DateTime.now();

  int selectedStartHour;
  int selectedStartMinute;
  int selectedEndHour;
  int selectedEndMinute;

  HourPicker integerStartHourPicker;
  MinutePicker integerStartMinutePicker;
  HourPicker integerEndHourPicker;
  MinutePicker integerEndMinutePicker;

  int _currentStartHour;
  int _currentStartMinute;
  int _currentEndHour;
  int _currentEndMinute;

  String errorMessage = "";

  void initState() {
    super.initState();

    _currentStartTime = DateTime.now().add(Duration(hours: 1));
    _currentStartHour = DateTime.now().add(Duration(hours: 1)).hour;
    _currentStartMinute = _handleMinute(DateTime.now().minute);
    _currentEndHour = DateTime.now().add(Duration(hours: 3)).hour;
    _currentEndMinute =
        _handleMinute(DateTime.now().add(Duration(minutes: 30)).minute);

    if (widget.startTime != null && widget.endTime != null) {
      _currentStartHour = widget.startTime.hour;
      _currentEndHour = widget.endTime.hour;
      _currentStartMinute = widget.startTime.minute;
      _currentEndMinute = widget.endTime.minute;
      selectedStartDate = widget.startTime;
      selectedEndDate = widget.endTime;
    }
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
    if (selectedStartDate.day != DateTime.now().day) {
      return Text(
        '${selectedStartDate.day}-${selectedStartDate.month}-${selectedStartDate.year}',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    } else if (_currentStartTime.day ==
            DateTime.now().add(Duration(hours: 1)).day &&
        DateTime.now().hour == 23) {
      selectedStartDate = DateTime.now().add(Duration(days: 1));
      return Text(
        '${selectedStartDate.day}-${selectedStartDate.month}-${selectedStartDate.year}',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    } else if (selectedStartDate.day == DateTime.now().day) {
      return Text(
        'Today',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget buildStartDeliverSelector() {
    integerStartHourPicker = new HourPicker.hour(
      maxValue: 23,
      minValue: 0,
      initialValue: _currentStartHour,
      step: 1,
      onChanged: (value) {
        _handleStartHourChanged(value);
      },
    );

    integerStartMinutePicker = new MinutePicker.minute(
      maxValue: 5,
      minValue: 0,
      initialValue: _currentStartMinute ~/ 10,
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

  _handleStartHourChanged(num value) {
    if (value != null) {
      setState(() => _currentStartHour = value);
    }
  }

  _handleStartMinuteChanged(num value) {
    if (value != null) {
      setState(() => _currentStartMinute = value);
    }
  }

  Widget buildTomorrow() {
    if (_currentEndHour < _currentStartHour &&
        selectedStartDate.day == DateTime.now().day &&
        selectedStartDate.month == DateTime.now().month &&
        selectedStartDate.year == DateTime.now().year) {
      selectedEndDate = selectedStartDate.add(Duration(days: 1));
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
            'Tomorrow',
            style: FontHelper.semiBold(Colors.black, 20),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (_currentEndHour < _currentStartHour &&
        selectedStartDate.day >= DateTime.now().day &&
        selectedStartDate.month >= DateTime.now().month &&
        selectedStartDate.year >= DateTime.now().year) {
      selectedEndDate = selectedStartDate.add(Duration(days: 1));
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
            '${selectedEndDate.day}-${selectedEndDate.month}-${selectedEndDate.year}',
            style: FontHelper.semiBold(Colors.black, 20),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      selectedEndDate = selectedStartDate;
      return Offstage();
    }
  }

  Widget buildEndDeliverSelector() {
    integerEndHourPicker = new HourPicker.hour(
      maxValue: 23,
      minValue: 0,
      initialValue: _currentEndHour,
      step: 1,
      onChanged: (value) {
        _handleEndHourChanged(value);
      },
    );

    integerEndMinutePicker = new MinutePicker.minute(
      maxValue: 5,
      minValue: 0,
      initialValue: _currentEndMinute ~/ 10,
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

  _handleEndHourChanged(num value) {
    if (value != null) {
      setState(() => _currentEndHour = value);
    }
  }

  _handleEndMinuteChanged(num value) {
    if (value != null) {
      setState(() => _currentEndMinute = value);
    }
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
          start = DateTime(
            selectedStartDate.year,
            selectedStartDate.month,
            selectedStartDate.day,
            _currentStartHour,
            _currentStartMinute,
          );
          end = DateTime(
            selectedEndDate.year,
            selectedEndDate.month,
            selectedEndDate.day,
            _currentEndHour,
            _currentEndMinute,
          );
          if (start.isAfter(DateTime.now().add(Duration(minutes: 50))) &&
              end.isAfter(start.add(Duration(minutes: 20)))) {
            print('confirmed start: $start');
            print('confirmed end: $end');
            Navigator.of(context).pop();
            widget.onCompleteCallBack(start, end);
          } else {
            print('wrong start: $start');
            print('wrong end: $end');
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
      initialDate: selectedStartDate,
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(2100),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedStartDate = DateTime(
            date.year,
            date.month,
            date.day,
          );
          selectedEndDate = DateTime(
            date.year,
            date.month,
            date.day,
          );
        });
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
  DateTime selectedStartDate = DateTime.now();
  DateTime start = DateTime.now();
  DateTime _currentStartTime = DateTime.now();

  int selectedStartHour;
  int selectedStartMinute;

  HourPicker integerStartHourPicker;
  MinutePicker integerStartMinutePicker;

  int _currentStartHour;
  int _currentStartMinute;

  String errorMessage = "";

  void initState() {
    super.initState();
    _currentStartTime = DateTime.now().add(Duration(hours: 1));
    _currentStartHour = DateTime.now().hour;
    _currentStartMinute =
        _handleMinute(DateTime.now().minute);
    if (widget.startTime != null) {
      _currentStartHour = widget.startTime.hour;
      _currentStartMinute = widget.startTime.minute;
      selectedStartDate = widget.startTime;
    }
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
          onTap: _selectDate,
          child: _handleDateToString(),
        ),
      ],
    );
  }

  _handleDateToString() {
    if (selectedStartDate.day != DateTime.now().day) {
      return Text(
        '${selectedStartDate.day}-${selectedStartDate.month}-${selectedStartDate.year}',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    } else if (selectedStartDate.day == DateTime.now().day) {
      return Text(
        'Today',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    }
  }

  // _handleDateToString() {
  //   if (selectedStartDate.day != DateTime.now().day) {
  //     return Text(
  //       '${selectedStartDate.day}-${selectedStartDate.month}-${selectedStartDate.year}',
  //       style: FontHelper.semiBold(Colors.black, 20),
  //       textAlign: TextAlign.center,
  //     );
  //   } else if (_currentStartTime.day ==
  //           DateTime.now().add(Duration(hours: 1)).day &&
  //       DateTime.now().hour == 23) {
  //     selectedStartDate = DateTime.now().add(Duration(days: 1));
  //     return Text(
  //       '${selectedStartDate.day}-${selectedStartDate.month}-${selectedStartDate.year}',
  //       style: FontHelper.semiBold(Colors.black, 20),
  //       textAlign: TextAlign.center,
  //     );
  //   } else if (selectedStartDate.day == DateTime.now().day) {
  //     return Text(
  //       'Today',
  //       style: FontHelper.semiBold(Colors.black, 20),
  //       textAlign: TextAlign.center,
  //     );
  //   }
  // }

  Widget buildStartDeliverSelector() {
    integerStartHourPicker = new HourPicker.hour(
      maxValue: 23,
      minValue: 0,
      initialValue: _currentStartHour,
      step: 1,
      onChanged: (value) {
        _handleStartHourChanged(value);
      },
    );

    integerStartMinutePicker = new MinutePicker.minute(
      maxValue: 5,
      minValue: 0,
      initialValue: _currentStartMinute ~/ 10,
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

  _handleStartHourChanged(num value) {
    if (value != null) {
      setState(() => _currentStartHour = value);
    }
  }

  _handleStartMinuteChanged(num value) {
    if (value != null) {
      setState(() => _currentStartMinute = value);
    }
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
          start = DateTime(
            selectedStartDate.year,
            selectedStartDate.month,
            selectedStartDate.day,
            _currentStartHour,
            _currentStartMinute,
          );
          if (start.isAfter(DateTime.now().subtract(Duration(minutes: 10)))) {
            print('confirmed start: $start');
            Navigator.of(context).pop();
            widget.onCompleteCallback(start);
          } else {
            print('wrong start: $start');
            setState(() {
              errorMessage = "At least from time now";
            });
          }
        },
      ),
    );
  }

  Future _selectDate() async {
    await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(2100),
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedStartDate = DateTime(
            date.year,
            date.month,
            date.day,
          );
        });
      }
    });
  }

  ///Round down minute to the nearest ten
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
