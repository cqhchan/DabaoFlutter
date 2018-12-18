import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Route/OverlayRoute.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';

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
  DateTime selectedDate;
  int selectedStartHour;
  int selectedStartMinute;
  int selectedEndHour;
  int selectedEndMinute;
  String errorMessage = "";

  void reset() {
    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    //Default selected hour to one hour from now
    selectedStartHour = DateTime.now().hour + 1;

    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    //Default selected minute to the nearest ten of the current minute
    // selectedStartMinute =
    //     _handleMinuteToString(DateTime.now().minute).toString();
    selectedStartMinute = DateTime.now().minute;

    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    //Default selected hour to one hour from now
    selectedEndHour = DateTime.now().hour + 3;

    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    //Default selected minute to the nearest ten of the current minute
    // selectedEndMinute = _handleMinuteToString(DateTime.now().minute).toString();
    selectedEndMinute = DateTime.now().minute;
  }

  void initState() {
    super.initState();

    selectedDate = DateTime.now();

    // ////////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////////
    // //Default selected hour to one hour from now
    selectedStartHour = DateTime.now().hour + 1;

    // ////////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////////
    // //Default selected minute to the nearest ten of the current minute
    // selectedStartMinute =
    //     _handleMinuteToString(DateTime.now().minute).toString();
    selectedStartMinute = DateTime.now().minute;

    // ////////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////////
    // //Default selected hour to one hour from now
    selectedEndHour = DateTime.now().hour + 3;

    // ////////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////////
    // //Default selected minute to the nearest ten of the current minute
    // selectedEndMinute = _handleMinuteToString(DateTime.now().minute).toString();
    selectedEndMinute = DateTime.now().minute;

    _buildClockSize(selectedStartHour, selectedStartMinute);
    _buildClockSize(selectedEndHour, selectedEndMinute);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Card(
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 220, maxHeight: 310),
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: ColorHelper.dabaoOrange,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: EdgeInsets.all(4.0),
                child: Row(
                  children: <Widget>[
                    buildClearButton(),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          buildHeader(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildSizedBox(),
                      buildDateSelector(),
                      buildSizedBox(),
                      buildStartDeliverSelector(),
                      buildEndDeliverSelector(),
                      buildSizedBox(),
                      buildErrorMessage(),
                      buildSizedBox(),
                      buildBottomButton(context)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Align buildClearButton() {
    return Align(
      child: IconButton(
        color: Colors.black,
        icon: Icon(Icons.clear),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Container buildHeader() {
    return Container(
      child: Column(
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
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: _handleDateToString(),
          ),
        )
      ],
    );
  }

  Row buildStartDeliverSelector() {
    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'Start: ',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _selectStartTime,
                child: _buildClockSize(selectedStartHour, selectedStartMinute),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row buildEndDeliverSelector() {
    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'End: ',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _selectEndTime,
                child: _buildClockSize(selectedEndHour, selectedEndMinute),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Expanded buildErrorMessage() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          child: Text(
            errorMessage,
            style: FontHelper.semiBold(Colors.red, 12.0),
          ),
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
                    alignment: Alignment.center,
                    child: Text(
                      "Confirm",
                      style: FontHelper.semiBold(Colors.black, 14.0),
                    ))),
          ],
        ),
        onPressed: () {
          if (selectedDate != null &&
              selectedStartHour != null &&
              selectedStartMinute != null &&
              selectedStartHour != selectedEndHour &&
              selectedStartHour < selectedEndHour &&
              selectedStartHour > selectedDate.hour) {
            DateTime start = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedStartHour,
              selectedStartMinute,
            );
            DateTime end = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedEndHour,
              selectedEndMinute,
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

  ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////
  //Date selection dialog
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
        setState(() {
          selectedDate = date;
        });
        reset();
      }
    });
  }

  ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////
  //Start hour selection dialog
  Future<TimeOfDay> _selectStartTime() => showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1))),
      ).then((value) {
        if (value != null) {
          setState(() {
            selectedStartHour = value.hour;
            selectedStartMinute = value.minute;
          });
        }
      });

  ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////
  //End hour selection dialog
  Future<TimeOfDay> _selectEndTime() => showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 3))),
      ).then((value) {
        if (value != null) {
          setState(() {
            selectedEndHour = value.hour;
            selectedEndMinute = value.minute;
          });
        }
      });

  _handleDateToString() {
    if (selectedDate.day == DateTime.now().day) {
      return Text(
        'Today',
        style: FontHelper.semiBold(Colors.black, 25),
        textAlign: TextAlign.center,
      );
    } else if (selectedDate.day == DateTime.now().day + 1) {
      return Text(
        'Tomorrow',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        '${selectedDate.day}-${selectedDate.month}-${selectedDate.year}',
        style: FontHelper.semiBold(Colors.black, 20),
        textAlign: TextAlign.center,
      );
    }
  }

  Text _buildClockSize(hour, minute) {
    return Text(
      '$hour:${_handleMinute(minute)}',
      style: FontHelper.semiBold(Colors.black, 45),
      textAlign: TextAlign.center,
    );
  }

  ////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////
  //1. Round up minute to the nearest ten
  //2. Round up to the nearest hour when minute is between 51 and 60
  _handleMinute(int value) {
    if (value < 10 || value == null) {
      return '00';
    } else if (value < 20 && value > 11) {
      return '10';
    } else if (value < 30 && value > 21) {
      return '20';
    } else if (value < 40 && value > 31) {
      return '30';
    } else if (value < 50 && value > 41) {
      return '40';
    } else if (value < 60 && value > 51) {
      return '50';
    }
  }
}
