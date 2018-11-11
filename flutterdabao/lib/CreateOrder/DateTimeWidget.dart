import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class DateTimePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => new _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  DateTime date;

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DateTimePickerFormField(
              format: dateFormat,
              onChanged: (dt) => setState(() => date = dt),
            ),
          ],
        ));
  }
}
