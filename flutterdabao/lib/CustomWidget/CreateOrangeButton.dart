import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/FoodTag.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class CreateOrangeButton extends StatefulWidget {
  CreateOrangeButton({
    Key key,
    @required this.imageAsset,
    @required this.text,
  });
  final String imageAsset;
  final String text;
  @override
  CreateOrangeButtonState createState() {
    return new CreateOrangeButtonState(imageAsset, text);
  }
}

class CreateOrangeButtonState extends State<CreateOrangeButton> {
  CreateOrangeButtonState(this.imageAsset, this.text);

  String imageAsset;
  String text;

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            color: ColorHelper.dabaoOffWhiteF5,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 10.0, color: ColorHelper.dabaoOrange),
                ),
              ),
              child: FoodTag(),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 9.0),
        color: ColorHelper.dabaoOrange,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(imageAsset),
            SizedBox(
              width: 5.0,
            ),
            Column(
              children: <Widget>[
                Text(text),
              ],
            ),
          ],
        ),
        onPressed: () {
          _showModalSheet();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
