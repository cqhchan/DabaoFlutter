import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:location/location.dart';
// import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  static LocationHelper get instance =>
      _internal != null ? _internal : LocationHelper();
  static LocationHelper _internal;

  Location location = new Location();

  //Ask for permission if user denied, do nothing
  Future<bool> softAskForPermission() {
    return location.hasPermission();
  }

  //Hard ask for permission if user denied, open dialog to direct to settings
  Future<bool> hardAskForPermission(
      BuildContext context, Text title, Text content) {
    return location.hasPermission().then((hasPermission) async {
      if (hasPermission)
        return true;
      else
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: title,
                content: content,
                actions: <Widget>[
                  new FlatButton(
                    child: new Text("DISMISS",style: FontHelper.regular(Colors.black, 14.0),),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("SETTINGS",style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),),
                    onPressed: () {
                      
                      // PermissionHandler().openAppSettings();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });

            return false;

    });
  }
}
