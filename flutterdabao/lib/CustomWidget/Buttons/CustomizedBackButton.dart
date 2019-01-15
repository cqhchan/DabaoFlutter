import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Headers/FloatingHeader.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';


///[onBack] if null it will can navigator.of(context).pop();
class CustomizedBackButton extends StatelessWidget {
  final VoidCallback onBack;

  const CustomizedBackButton({Key key, this.onBack}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FloatingHeader(
      opacityProperty: MutableProperty<double>(0.0),
      leftButton: GestureDetector(
        child: Container(
          child: Image.asset(
            "assets/icons/arrow-left-round.png",
            fit: BoxFit.fill,
          ),
        height: 40.0,
        width: 40.0,),
        onTap: (){
          if (onBack ==  null)
          Navigator.of(context).pop();
          else 
          onBack();
        },
      ),
    );
  }
}
