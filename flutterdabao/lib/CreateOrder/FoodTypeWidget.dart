import 'package:card_settings/card_settings.dart';

import 'package:flutter/material.dart';

import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

List<String> category = [
  'Al Ameens Stretch',
  'Bubble Tea',
  'Canteen',
  'FastFood',
  'Hawker'
];
List<String> subcategory = [
  'Al Ameens Stretch',
  'Bubble Tea',
  'Canteen',
  'FastFood',
  'Hawker'
];

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class FoodType extends StatefulWidget {
  @override
  _FoodTypeState createState() => new _FoodTypeState();
}

class _FoodTypeState extends State<FoodType> {
  String mycategory;
  String mysubcategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
        child: CardSettings(
          children: <Widget>[
            CardSettingsHeader(label: 'Food Type'),
            CardSettingsListPicker(
              label: 'Category',
              onSaved: (value) => mycategory = value,
              onChanged: (value) {
                setState(() {
                  mycategory = value;
                });
              },
              options: category,
            ),
            CardSettingsListPicker(
              options: subcategory,
              label: 'Sub - Category',
              onSaved: (value) => mysubcategory = value,
              onChanged: (value) {
                setState(() {
                  mysubcategory = value;
                });
              },
            ),
            CardSettingsButton(
              onPressed: () {
                print('You have selected $mycategory and $mysubcategory');
              },
              label: 'SELECT',
              backgroundColor: kOrderButton,
              bottomSpacing: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}
