import 'package:flutter/material.dart';

import './initial/login.dart';
import 'default.dart';

class DabaoApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dabao',
      home: HomePage(),
      initialRoute: '/login',
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
    );
  }
}

// final ThemeData _kShrineTheme = _buildShrineTheme();

// ThemeData _buildShrineTheme() {
//   final ThemeData base = ThemeData.light();
//   return base.copyWith(
//     accentColor: kShrineBrown900,
//     primaryColor: kShrinePink100,
//     buttonColor: kShrinePink100,
//     scaffoldBackgroundColor: kShrineBackgroundWhite,
//     cardColor: kShrineBackgroundWhite,
//     textSelectionColor: kShrinePink100,
//     errorColor: kShrineErrorRed,
//     buttonTheme: ButtonThemeData(
//       textTheme: ButtonTextTheme.accent,
//     ),
//     primaryIconTheme: base.iconTheme.copyWith(
//         color: kShrineBrown900
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(),
//     ),
//     textTheme: _buildShrineTextTheme(base.textTheme),
//     primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
//     accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
//   );
// }

// TextTheme _buildShrineTextTheme(TextTheme base) {
//   return base.copyWith(
//     headline: base.headline.copyWith(
//       fontWeight: FontWeight.w500,
//     ),
//     title: base.title.copyWith(
//         fontSize: 18.0
//     ),
//     caption: base.caption.copyWith(
//       fontWeight: FontWeight.w400,
//       fontSize: 14.0,
//     ),
//     body2: base.body2.copyWith(
//       fontWeight: FontWeight.w500,
//       fontSize: 16.0,
//     ),
//   ).apply(
//     fontFamily: 'Rubik',
//     displayColor: kShrineBrown900,
//     bodyColor: kShrineBrown900,
//   );
// }
