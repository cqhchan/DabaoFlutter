import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Route/OverlayRoute.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:rxdart/rxdart.dart';

typedef DoubleDateSelectedCallback = Function(DateTime, DateTime);
typedef DateSelectedCallback = Function(DateTime);

Future<T> showTimeCreator<T>({
  @required BuildContext context,
  bool barrierDismissible = true,
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
  int minutes = 30,
  bool barrierDismissible = true,
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
        mintutes: minutes,
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

  _TimePickerEditor({
    Key key,
    @required this.onCompleteCallBack,
    this.startTime,
    this.endTime,
    this.minsGapBetweenStartAndEndTime = 0,
    this.startTimeBeforeLimitInMins = 0,
  }) : super(key: key);
  _TimePickerEditorState createState() => _TimePickerEditorState();
}

class _TimePickerEditorState extends State<_TimePickerEditor>
    with HavingSubscriptionMixin {
  MutableProperty<DateTime> selectedStartDate;
  MutableProperty<DateTime> selectedEndDate;

  DateTime selectedStartDateByCalander;
  DateTime currentTime;
  DateTime startTime;

  String errorMessage = "";

  void initState() {
    super.initState();
    currentTime = DateTime.now();
    startTime = currentTime.add(Duration(hours: 1, minutes: 15));
    // Copy Start time to prevent unwanted editting
    selectedStartDate = MutableProperty<DateTime>(widget.startTime != null
        ? DateTime.fromMillisecondsSinceEpoch(
            widget.startTime.millisecondsSinceEpoch)
        : startTime);
    selectedStartDateByCalander = DateTime(
        selectedStartDate.value.year,
        selectedStartDate.value.month,
        selectedStartDate.value.day,
        selectedStartDate.value.minute,
        selectedStartDate.value.second);

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
    subscription.add(Observable.combineLatest2(
        selectedStartDate.producer, selectedEndDate.producer,
        (startDate, endDate) {
      if (selectedStartDate.value.isAfter(DateTime.now()
              .add(Duration(minutes: widget.startTimeBeforeLimitInMins))) &&
          selectedEndDate.value.isAfter(selectedStartDate.value
              .add(Duration(minutes: widget.minsGapBetweenStartAndEndTime)))) {
        return "";
      } else {
        return "Error: Time Selected must be \n - At least 1 hour from now\n - 30 minutes apart";
      }
    }).listen((error) {
      setState(() {
        errorMessage = error;
      });
    }));
    ;
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Card(
              elevation: 0.0,
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                // ),
              ),
            ),
          ],
        ),
      ],
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
//TODO p2 Enlarge time picker font

  Widget buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.dabaoOrange,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Stack(
        children: <Widget>[
          buildClearButton(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Schedule Your Order',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'Start: ',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        GestureDetector(
          onTap: () async {
            // if (Platform.isIOS) {
            await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newDateTime) {
                      if (newDateTime.isBefore(startTime)) {
                        newDateTime = newDateTime.add(Duration(days: 1));
                      }
                      selectedStartDate.value = newDateTime;
                    },
                    initialDateTime: selectedStartDate.value,
                  );
                });
          },
          child: StreamBuilder(
            stream: selectedStartDate.producer,
            builder: (context, snap) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      width: 140,
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            snap.data != null
                                ? DateTimeHelper.hourAndMin12Hour(snap.data)
                                : "00:00",
                            style: FontHelper.semiBold(Colors.black, 45),
                            textAlign: TextAlign.center,
                          ))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                          snap.data != null
                              ? formatDate(snap.data, [am])
                              : "AM",
                          style: FontHelper.semiBold(Colors.black, 22)),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
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
    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'End: ',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        GestureDetector(
          onTap: () async {
            // if (Platform.isIOS) {
            await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newDateTime) {
                      selectedEndDate.value = newDateTime;
                    },
                    initialDateTime: selectedEndDate.value,
                  );
                });
            // } else {
            //   TimeOfDay tempEndTimeOfDay = await showTimePicker(
            //       context: context,
            //       initialTime: TimeOfDay.fromDateTime(selectedEndDate.value));

            //   if (tempEndTimeOfDay != null) {
            //     DateTime tempSelectedTime = selectedEndDate.value;

            //     DateTime newDateTime = DateTime(
            //         tempSelectedTime.year,
            //         tempSelectedTime.month,
            //         tempSelectedTime.day,
            //         tempEndTimeOfDay.hour,
            //         tempEndTimeOfDay.minute);
            //     selectedEndDate.value = newDateTime;
            //   }
            // }
          },
          child: StreamBuilder(
            stream: selectedEndDate.producer,
            builder: (context, snap) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      width: 140,
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            snap.data != null
                                ? DateTimeHelper.hourAndMin12Hour(snap.data)
                                : "00:00",
                            style: FontHelper.semiBold(Colors.black, 45),
                          ))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                          snap.data != null
                              ? formatDate(snap.data, [am])
                              : "AM",
                          style: FontHelper.semiBold(Colors.black, 22)),
                    ),
                  )
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildErrorMessage() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Text(
          errorMessage,
          style: FontHelper.semiBold(ColorHelper.dabaoErrorRed, 12.0),
          textAlign: TextAlign.start,
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
        child: Stack(
          alignment: Alignment(0.0, 0.0),
          children: <Widget>[
            Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.access_time)),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Confirm",
                style: FontHelper.semiBold(Colors.black, 14.0),
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
                  "Error: Time Selected must be \n - At least 1 hour from now\n - 30 minutes apart";
            });
          }
        },
      ),
    );
  }

  Future _selectDate() async {
    // if (Platform.isIOS)
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (DateTime date) {
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
            },
            initialDateTime: selectedStartDate.value,
            minimumYear: DateTime.now().year,
            maximumYear: DateTime.now().year + 1,
          );
        });
    // else
    //   await showDatePicker(
    //     context: context,
    //     initialDate: selectedStartDate.value,
    //     firstDate: DateTime(
    //         DateTime.now().year, DateTime.now().month, DateTime.now().day),
    //     lastDate: DateTime(DateTime.now().year + 1),
    //   ).then((date) {
    //     if (date != null) {
    //       selectedStartDateByCalander = date;
    //       selectedStartDate.value = DateTime(
    //           selectedStartDateByCalander.year,
    //           selectedStartDateByCalander.month,
    //           selectedStartDateByCalander.day,
    //           selectedStartDate.value.hour,
    //           selectedStartDate.value.minute,
    //           selectedStartDate.value.second);
    //     }
    // });
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
  final int mintutes;

  const _OnetimePickerEditor({
    Key key,
    @required this.onCompleteCallback,
    this.startTime,
    this.headerTitle,
    this.subTitle,
    @required this.mintutes,
  }) : super(key: key);

  __OneTimePickerEditorState createState() => __OneTimePickerEditorState();
}

class __OneTimePickerEditorState extends State<_OnetimePickerEditor> {
  MutableProperty<DateTime> selectedStartDate;
  DateTime _currentStartTime;

  String errorMessage = "";

  void initState() {
    super.initState();

    _currentStartTime = DateTime.now().add(Duration(minutes: widget.mintutes));
    if (widget.startTime == null)
      selectedStartDate =
          MutableProperty(DateTime.now().add(Duration(minutes: 30)));
    else
      selectedStartDate = MutableProperty(widget.startTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 240),
                child: Card(
                  elevation: 0.0,
                  margin: EdgeInsets.all(0),
                  color: Colors.transparent,
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
            )
          ])
        ]);
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
    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'Start: ',
            style: TextStyle(color: ColorHelper.dabaoOffBlack9B),
          ),
        ),
        GestureDetector(
          onTap: () async {
            // if (Platform.isIOS) {
            await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newDateTime) {
                      if (newDateTime.isBefore(_currentStartTime)) {
                        newDateTime = newDateTime.add(Duration(days: 1));
                      }
                      if (newDateTime
                          .isAfter(_currentStartTime.add(Duration(days: 1)))) {
                        newDateTime = newDateTime.subtract(Duration(days: 1));
                      }
                      selectedStartDate.value = newDateTime;
                    },
                    initialDateTime: selectedStartDate.value,
                  );
                });
            // } else {
            //   TimeOfDay tempStartTimeOfDay = await showTimePicker(
            //       context: context,
            //       initialTime: TimeOfDay.fromDateTime(selectedStartDate.value));
            //   if (tempStartTimeOfDay != null) {
            //     DateTime tempSelectedTime = selectedStartDate.value;

            //     DateTime newDateTime = DateTime(
            //         tempSelectedTime.year,
            //         tempSelectedTime.month,
            //         tempSelectedTime.day,
            //         tempStartTimeOfDay.hour,
            //         tempStartTimeOfDay.minute);

            //     if (newDateTime.isBefore(_currentStartTime)) {
            //       newDateTime = newDateTime.add(Duration(days: 1));
            //     }
            //     selectedStartDate.value = newDateTime;
            //   }
            // }
          },
          child: StreamBuilder(
            stream: selectedStartDate.producer,
            builder: (context, snap) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      width: 140,
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              snap.data != null
                                  ? DateTimeHelper.hourAndMin12Hour(snap.data)
                                  : "00:00",
                              style: FontHelper.semiBold(Colors.black, 45)))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                          snap.data != null
                              ? formatDate(snap.data, [am])
                              : "AM",
                          style: FontHelper.semiBold(Colors.black, 22)),
                    ),
                  )
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget buildErrorMessage() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: Text(
          errorMessage,
          style: FontHelper.semiBold(ColorHelper.dabaoErrorRed, 12.0),
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
        child: Stack(
          alignment: Alignment(0.0, 0.0),
          children: <Widget>[
            Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.access_time)),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Confirm",
                style: FontHelper.semiBold(Colors.black, 14.0),
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
