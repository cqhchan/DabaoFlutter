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
  DateTime selectedStartDate;
  DateTime selectedEndDate;

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

  DateTime start;
  DateTime end;

  void reset() {
    //Default selected hour to one hour from now
    _currentStartHour = _handleMoreThan24Hours(DateTime.now().hour + 1);

    //Default selected minute round down to the nearest ten of the current minute
    _currentStartMinute = _handleMinute(DateTime.now().minute);

    //Default selected hour to two hours from now
    _currentEndHour = _handleMoreThan24Hours(DateTime.now().hour + 2);

    //Default selected minute round down to the nearest ten of the current minute
    _currentEndMinute = _handleMinute(DateTime.now().minute);
  }

  void initState() {
    super.initState();

    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();

    reset();

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
  void dispose() {
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

  Row buildTomorrow() {
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
      return Row(
        children: <Widget>[Offstage()],
      );
    }
  }

  Row buildEndDeliverSelector() {
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

  Align buildErrorMessage() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Text(
          errorMessage,
          style: FontHelper.semiBold(Colors.red, 12.0),
        ),
      ),
    );
  }

  Align buildBottomButton(BuildContext context) {
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
          if (selectedStartDate != null &&
              _currentStartHour != null &&
              _currentStartMinute != null &&
              _currentEndHour != null &&
              _currentEndMinute != null &&
              _currentStartHour != _currentEndHour &&
              _currentStartHour > DateTime.now().hour) {
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
            Navigator.of(context).pop();
            widget.onCompleteCallBack(start,end);
          } else {
            setState(() {
              errorMessage = "Please input the correct time period";
            });
          }
        },
      ),
    );
  }

  ///Date selection dialog
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

  _handleDateToString() {
    if (selectedStartDate.day == DateTime.now().day) {
      return Text(
        'Today',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        '${selectedStartDate.day}-${selectedStartDate.month}-${selectedStartDate.year}',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    }
  }

  _handleMoreThan24Hours(int value) {
    return value = value >= 24 ? value - 24 : value;
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

  ///This method returns integer for minimum value for time picker.
  ///If the [SelectedStartDate] is current date, it will returns a ((current hour) + 1).
  ///Else it will return an integer 0.
  _handleMinValue() {
    if (selectedStartDate.day == DateTime.now().day &&
        selectedStartDate.month == DateTime.now().month &&
        selectedStartDate.year == DateTime.now().year) {
      return _handleMoreThan24Hours(DateTime.now().hour + 1);
    } else {
      return 0;
    }
  }
}

class _OnetimePickerEditor extends StatefulWidget {
  final DateSelectedCallback onCompleteCallback;
  final startTime;

  const _OnetimePickerEditor({
    Key key,
    @required this.onCompleteCallback,
    this.startTime,
  }) : super(key: key);

  __OneTimePickerEditorState createState() => __OneTimePickerEditorState();
}

class __OneTimePickerEditorState extends State<_OnetimePickerEditor> {
  DateTime selectedStartDate;

  int selectedStartHour;
  int selectedStartMinute;

  HourPicker integerStartHourPicker;
  MinutePicker integerStartMinutePicker;

  int _currentStartHour;
  int _currentStartMinute;

  String errorMessage = "";

  DateTime start;

  void reset() {
    //Default selected hour to one hour from now
    _currentStartHour = _handleMoreThan24Hours(DateTime.now().hour + 1);

    //Default selected minute round down to the nearest ten of the current minute
    _currentStartMinute = _handleMinute(DateTime.now().minute);
  }

  void initState() {
    super.initState();

    selectedStartDate = DateTime.now();

    reset();

    if (widget.startTime != null) {
      _currentStartHour = widget.startTime.hour;
      _currentStartMinute = widget.startTime.minute;
      selectedStartDate = widget.startTime;
    }
  }

  @override
  void dispose() {
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

  Align buildErrorMessage() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Text(
          errorMessage,
          style: FontHelper.semiBold(Colors.red, 12.0),
        ),
      ),
    );
  }

  Align buildBottomButton(BuildContext context) {
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
          if (selectedStartDate != null &&
              _currentStartHour != null &&
              _currentStartMinute != null &&
              _currentStartHour > DateTime.now().hour) {
            start = DateTime(
              selectedStartDate.year,
              selectedStartDate.month,
              selectedStartDate.day,
              _currentStartHour,
              _currentStartMinute,
            );
            widget.onCompleteCallback(start);
            Navigator.of(context).pop();
          } else {
            setState(() {
              errorMessage = "Please input the correct time period";
            });
          }
        },
      ),
    );
  }

  ///Date selection dialog
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

  _handleDateToString() {
    if (selectedStartDate.day == DateTime.now().day) {
      return Text(
        'Today',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        '${selectedStartDate.day}-${selectedStartDate.month}-${selectedStartDate.year}',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    }
  }

  _handleMoreThan24Hours(int value) {
    return value = value >= 24 ? value - 24 : value;
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

  ///This method returns integer for minimum value for time picker.
  ///If the [SelectedStartDate] is current date, it will returns a ((current hour) + 1).
  ///Else it will return an integer 0.
  _handleMinValue() {
    if (selectedStartDate.day == DateTime.now().day &&
        selectedStartDate.month == DateTime.now().month &&
        selectedStartDate.year == DateTime.now().year) {
      return _handleMoreThan24Hours(DateTime.now().hour + 1);
    } else {
      return 0;
    }
  }
}
