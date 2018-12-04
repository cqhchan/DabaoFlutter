// // Copyright 2018 The Chromium Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.
import 'package:flutterdabao/CustomWidget/Map.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

import 'package:flutter/material.dart';

class FoodTag extends StatefulWidget {
  _FoodTagState createState() => _FoodTagState();
}

class _FoodTagState extends State<FoodTag> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('FoodTag', style: FontHelper.semiBold14Black),
                Text('Select one', style: FontHelper.headerTextStyle),
              ],
            ),
            Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.grey.shade800,
                child: Text('AB'),
              ),
              label: Text('Aaron Burr'),
            ),
          ],
        ),
      ),
    );
  }
}
