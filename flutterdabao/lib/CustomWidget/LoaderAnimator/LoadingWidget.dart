import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterdabao/CustomWidget/Route/OverlayRoute.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

Future<T> showLoadingOverlay<T>({
  @required BuildContext context,
  bool barrierDismissible = false,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: true)
      .push<T>(CustomOverlayRoute<T>(
    builder: (context) {
      return LoadingPage(transparent: true,);
    },
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}


class LoadingPage extends StatefulWidget {

  final bool transparent;

  const LoadingPage({Key key, this.transparent = false}) : super(key: key);

  @override
  _LoadingPageState createState() => new _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: widget.transparent ? Colors.transparent : ColorHelper.dabaoOffWhiteF5,
          body: Center(
        child: CircularProgressIndicator(
                      value: null,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ColorHelper.dabaoOrange),
                      strokeWidth: 7.0,
                    ),
      ),
    );
    
  }
}
