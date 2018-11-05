import 'package:card_settings/card_settings.dart';

import 'package:flutter/material.dart';

import '../style/home_style.dart';

String title = "Spheria";
String author = "Cody Leet";
String url = "http://www.codyleet.com/spheria";

List<String> subcategory = ['Al Ameens Stretch','Bubble Tea','Canteen','FastFood','Hawker'];
List<String> category = ['Al Ameens Stretch','Bubble Tea','Canteen','FastFood','Hawker'];


final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class FoodType extends StatefulWidget {
  @override
  _FoodTypeState createState() => new _FoodTypeState();
}

class _FoodTypeState extends State<FoodType> {
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
              onSaved: (value) => title = value,
              options: category,
            ),
            CardSettingsListPicker(
              options: subcategory,
              label: 'Sub - Category',
              onSaved: (value) => url = value,
            ),
            CardSettingsButton(
              onPressed: null, 
              label: 'SELECT', 
              backgroundColor: kOrderButton, 
              bottomSpacing: 4.0,),
          ],
        ),
      ),
    );
  }
}
