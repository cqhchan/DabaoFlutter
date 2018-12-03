import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/Searchable.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'dart:async';

class LocateWidget extends StatefulWidget {
  _LocateWidgetState createState() => _LocateWidgetState();
}

class _LocateWidgetState extends State<LocateWidget> {
  // final _addressController = TextEditingController();

  // String _address;
  DateTime _startTime = new DateTime.now();
  DateTime _endTime = new DateTime.now().add(Duration(hours: 1));

  Future<Null> _selectStartTime(BuildContext context) async {
    final TimeOfDay pickedStart = await showTimePicker(
      context: null,
      initialTime: TimeOfDay.now(),
    );
  }

  Future<Null> _selectEndTime(BuildContext context) async {
    final TimeOfDay pickedEnd = await showTimePicker(
      context: null,
      initialTime: TimeOfDay.now(),
    );
  }

  // if(pickedStart != null && pickedStart != _startTime) {
  //   print('Start Time Selected: ${_startTime.toString()}');
  //   setState(() {
  //         _startTime = pickedStart;
  //       });
  // }

  // if(pickedEnd != null && pickedEnd != _endTime) {
  //   print('End Time Selected: ${_endTime.toString()}');
  //   setState(() {
  //         _startTime = pickedEnd;
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(14.0),
            margin: EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 30.0),
            height: 130.0,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                  )
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Deliver to...',
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: <Widget>[
                    Image.asset(
                      'assets/icons/pin.png',
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    GestureDetector(
                      child: Container(
                        child: Text('20 Heng Mui Keng Terrace'),
                      ),
                      // child: TextField(
                      //   controller: _addressController,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       address = value;
                      //     });
                      //   },
                      // ),
                      onTap: () {
                        // FocusScope.of(context).requestFocus FocusNode());
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Searchable()),
                        );
                      },
                    ),
                  ],
                ),
                Divider(height: 15.0, indent: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    OutlineButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      color: ColorHelper.dabaoOffWhiteF5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Image.asset('assets/icons/stand.png'),
                          SizedBox(
                            width: 5.0,
                          ),
                          Column(
                            children: <Widget>[
                              Text('Scheduled'),
                              Text('Order'),
                            ],
                          ),
                        ],
                      ),
                      onPressed: () {
                        _selectStartTime(context);
                        _selectEndTime(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    RaisedButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 22.0, vertical: 9.0),
                      color: ColorHelper.dabaoOrange,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/icons/run.png'),
                          SizedBox(
                            width: 5.0,
                          ),
                          Column(
                            children: <Widget>[
                              Text('Order Now'),
                            ],
                          ),
                        ],
                      ),
                      onPressed: () {
                        print('hi');
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Wrap(
//       alignment: WrapAlignment.end,
//       spacing: 20.0,
//       children: <Widget>[
//         Container(
//           padding: EdgeInsets.all(18.0),
//           margin: EdgeInsets.all(12.0),
//           height: 128.0,
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(9.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey,
//                   blurRadius: 5.0,
//                 )
//               ]),
//           child: Column(
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   Column(
//                     children: <Widget>[
//                       Icon(
//                         Icons.location_on,
//                         color: Colors.red,
//                         size: 35.0,
//                       ),
//                     ],
//                   ),
//                   Flexible(
//                     child: TextField(),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//       // alignment: Alignment.center,
//       // padding: EdgeInsets.all(18.0),
//       // margin: EdgeInsets.all(12.0),
//     );
