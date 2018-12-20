import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Route/OverlayRoute.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/TimePicker/ScrollableNumberPicker.dart';

typedef DateSelectedCallback = Function(DateTime);

Future<T> showtimeCreator<T>({
  @required BuildContext context,
  bool barrierDismissible = false,
  @required DateSelectedCallback startDeliveryTimeCallback,
  @required DateSelectedCallback endDeliveryTimeCallback,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: true)
      .push<T>(CustomOverlayRoute<T>(
    builder: (context) {
      return _TimePickerEditor(
        startDeliveryOnComplete: startDeliveryTimeCallback,
        endDeliveryOnComplete: endDeliveryTimeCallback,
      );
    },
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}

class _TimePickerEditor extends StatefulWidget {
  final DateSelectedCallback startDeliveryOnComplete;
  final DateSelectedCallback endDeliveryOnComplete;
  final OrderHolder orderHolder;

  const _TimePickerEditor(
      {Key key,
      @required this.startDeliveryOnComplete,
      this.orderHolder,
      @required this.endDeliveryOnComplete})
      : super(key: key);

  __TimePickerEditorState createState() => __TimePickerEditorState();
}

class __TimePickerEditorState extends State<_TimePickerEditor> {
  DateTime selectedStartDate;
  DateTime selectedEndDate;

  int selectedStartHour;
  int selectedStartMinute;
  int selectedEndHour;
  int selectedEndMinute;

  NumberPicker integerStartHourPicker;
  NumberPicker integerStartMinutePicker;
  NumberPicker integerEndHourPicker;
  NumberPicker integerEndMinutePicker;

  int _currentStartHour;
  int _currentStartMinute;
  int _currentEndHour;
  int _currentEndMinute;

  String errorMessage = "";

  void reset() {
    //Default selected hour to one hour from now
    _currentStartHour = _handleMoreThan24Hours(DateTime.now().hour + 1);

    //Default selected minute to the nearest ten of the current minute
    _currentStartMinute = DateTime.now().minute;

    //Default selected hour to two hours from now
    _currentEndHour = _handleMoreThan24Hours(DateTime.now().hour + 2);

    //Default selected minute to the nearest ten of the current minute
    _currentEndMinute = DateTime.now().minute;
  }

  void initState() {
    super.initState();

    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();

    reset();
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
      body: Card(
        margin: EdgeInsets.fromLTRB(50, 50, 50, 150),
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: ColorHelper.dabaoOrange,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                children: <Widget>[
                  buildClearButton(),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: buildHeader(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Wrap(
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

  Column buildHeader() {
    return Column(
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
    integerStartHourPicker = new NumberPicker.integer(
      maxValue: 23,
      minValue: _handleMinValue(),
      initialValue: _currentStartHour,
      step: 1,
      onChanged: (value) {
        _handleStartHourChanged(value);
      },
    );

    integerStartMinutePicker = new NumberPicker.integer(
      maxValue: 59,
      minValue: 0,
      initialValue: _currentStartMinute,
      step: 1,
      onChanged: (value) {
        _handleStartMinuteChanged(value);
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
    integerEndHourPicker = new NumberPicker.integer(
      maxValue: 23,
      minValue: 0,
      initialValue: _currentEndHour,
      step: 1,
      onChanged: (value) {
        _handleEndHourChanged(value);
      },
    );

    integerEndMinutePicker = new NumberPicker.integer(
      maxValue: 59,
      minValue: 0,
      initialValue: _currentEndMinute,
      step: 1,
      onChanged: (value) {
        _handleEndMinuteChanged(value);
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
              _currentStartHour != _currentEndHour) {
            DateTime start = DateTime(
              selectedStartDate.year,
              selectedStartDate.month,
              selectedStartDate.day,
              _currentStartHour,
              _currentStartMinute,
            );
            DateTime end = DateTime(
              selectedEndDate.year,
              selectedEndDate.month,
              selectedEndDate.day,
              _currentEndHour,
              _currentEndMinute,
            );
            widget.startDeliveryOnComplete(start);
            widget.endDeliveryOnComplete(end);
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
      initialDate: DateTime.now(),
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 7),
    ).then((date) {
      if (date != null) {
        reset();
        setState(() {
          selectedStartDate = date;
          selectedEndDate = date;
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

  ///This method returns integer for minimum value for time picker.
  ///If the [SelectedStartDate] is current date, it will returns a ((current hour) + 1).
  ///Else it will return an integer 0.
  _handleMinValue() {
    if (selectedStartDate.day == DateTime.now().day &&
        selectedStartDate.month == DateTime.now().month &&
        selectedStartDate.year == DateTime.now().year) {
      return _handleMoreThan24Hours(DateTime.now().hour + 1);
    } else if (selectedStartDate.day >= DateTime.now().day &&
        selectedStartDate.month >= DateTime.now().month &&
        selectedStartDate.year >= DateTime.now().year) {
      return DateTime.now().hour;
    } else {
      return 0;
    }
  }
}
