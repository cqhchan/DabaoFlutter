import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutterdabao/CreateOrder/DateSlot.dart';

class DatePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => new _DateTimePickerState();
}

class _DateTimePickerState extends State<DatePicker> {
  // final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  // DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new DateSlotPicker(
        onTap: (DateTime startDate, DateTime endTime) {
          print(startDate.toString());
        },
      ),
    );
  }
}

// new Container(
//         padding: EdgeInsets.all(16.0),
//         child: new Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             DateTimePickerFormField(
//               format: dateFormat,
//               resetIcon: Icons.close,
//               onChanged: (dt) => setState(() => date = dt),
//             ),
//           ],
//         ));
