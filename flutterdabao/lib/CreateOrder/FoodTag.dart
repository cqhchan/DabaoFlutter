import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

import 'package:flutter/material.dart';

class FoodTag extends StatefulWidget {
  _FoodTagState createState() => _FoodTagState();
}

class _FoodTagState extends State<FoodTag> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Food Tag',
                    style: FontHelper.header2TextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Select one',
                    style: FontHelper.normalTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Container(
              color: ColorHelper.dabaoOffWhiteF5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                    child: Text(
                      'Being deliver near you',
                      style: FontHelper.normalTextStyle,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 5.0,
              direction: Axis.horizontal,
              children: <Widget>[
                InputChip(
                  pressElevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: ColorHelper.dabaoOrange,
                          style: BorderStyle.solid)),
                  backgroundColor: ColorHelper.dabaoOffWhiteF5,
                  label: Text(
                    'KOI',
                    style: FontHelper.chipTextStyle,
                  ),
                  onPressed: () {},
                ),
                InputChip(
                  pressElevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: ColorHelper.dabaoOrange,
                          style: BorderStyle.solid)),
                  backgroundColor: ColorHelper.dabaoOffWhiteF5,
                  label: Text(
                    'GongCha',
                    style: FontHelper.chipTextStyle,
                  ),
                  onPressed: () {},
                ),
                InputChip(
                  pressElevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: ColorHelper.dabaoOrange,
                          style: BorderStyle.solid)),
                  backgroundColor: ColorHelper.dabaoOffWhiteF5,
                  label: Text(
                    'ShareTea',
                    style: FontHelper.chipTextStyle,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            Divider(height: 15.0, indent: 20.0),
            SizedBox(
              height: 10,
            ),
            Wrap(
              spacing: -1.5,
              alignment: WrapAlignment.end,
              direction: Axis.horizontal,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (pressed == false) {
                        pressed = true;
                      } else {
                        pressed = false;
                      }
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: pressed
                          ? ColorHelper.dabaoOrange
                          : ColorHelper.dabaoOffWhiteF5,
                      borderRadius: BorderRadius.circular(1.0),
                      border: Border.all(
                        color: ColorHelper.dabaoOrange,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      'Bubble Tea',
                      style: FontHelper.normalTextStyle,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (pressed == false) {
                        pressed = true;
                      } else {
                        pressed = false;
                      }
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: pressed
                          ? ColorHelper.dabaoOrange
                          : ColorHelper.dabaoOffWhiteF5,
                      borderRadius: BorderRadius.circular(1.0),
                      border: Border.all(
                        color: ColorHelper.dabaoOrange,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      'Fast Food',
                      style: FontHelper.normalTextStyle,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (pressed == false) {
                        pressed = true;
                      } else {
                        pressed = false;
                      }
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: pressed
                          ? ColorHelper.dabaoOrange
                          : ColorHelper.dabaoOffWhiteF5,
                      borderRadius: BorderRadius.circular(1.0),
                      border: Border.all(
                        color: ColorHelper.dabaoOrange,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      'Nearby',
                      style: FontHelper.normalTextStyle,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (pressed == false) {
                        pressed = true;
                      } else {
                        pressed = false;
                      }
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: pressed
                          ? ColorHelper.dabaoOrange
                          : ColorHelper.dabaoOffWhiteF5,
                      borderRadius: BorderRadius.circular(1.0),
                      border: Border.all(
                        color: ColorHelper.dabaoOrange,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      'Others',
                      style: FontHelper.normalTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 5.0,
              direction: Axis.horizontal,
              children: <Widget>[
                InputChip(
                  pressElevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: ColorHelper.dabaoOrange,
                          style: BorderStyle.solid)),
                  backgroundColor: ColorHelper.dabaoOffWhiteF5,
                  label: Text(
                    'Biz Canteen',
                    style: FontHelper.chipTextStyle,
                  ),
                  onPressed: () {},
                ),
                InputChip(
                  pressElevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: ColorHelper.dabaoOrange,
                          style: BorderStyle.solid)),
                  backgroundColor: ColorHelper.dabaoOffWhiteF5,
                  label: Text(
                    'Science Canteen',
                    style: FontHelper.chipTextStyle,
                  ),
                  onPressed: () {},
                ),
                InputChip(
                  pressElevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: ColorHelper.dabaoOrange,
                          style: BorderStyle.solid)),
                  backgroundColor: ColorHelper.dabaoOffWhiteF5,
                  label: Text(
                    'Arts Canteen',
                    style: FontHelper.chipTextStyle,
                  ),
                  onPressed: () {},
                ),
                InputChip(
                  pressElevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: ColorHelper.dabaoOrange,
                          style: BorderStyle.solid)),
                  backgroundColor: ColorHelper.dabaoOffWhiteF5,
                  label: Text(
                    'Ai Ameens',
                    style: FontHelper.chipTextStyle,
                  ),
                  onPressed: () {},
                ),
                InputChip(
                  pressElevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                          color: ColorHelper.dabaoOrange,
                          style: BorderStyle.solid)),
                  backgroundColor: ColorHelper.dabaoOffWhiteF5,
                  label: Text(
                    'Naan Thai',
                    style: FontHelper.chipTextStyle,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  color: ColorHelper.dabaoOrange,
                  icon: Icon(Icons.add_circle_outline),
                  tooltip: 'To add tag',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
