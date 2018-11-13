import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:time_slot_picker/time_slot_picker.dart';

class DateTimePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => new _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  // final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  // DateTime date;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Container(
            color: Colors.red,
            child: new TimeSlotPicker(
              date:
                  new DateTime.now(),// (Optional)
              slotBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)), // (Optional)
              textStyle: TextStyle(color: Colors.white), // (Optional)
              onTap: (DateTime startTime, DateTime endTime) {
                // (Required)
                print(startTime.toString() + " >> " + endTime.toString());
              },
            ),
          ),
        ],
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
