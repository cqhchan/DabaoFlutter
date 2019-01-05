import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';

class FloatingHeader extends StatefulWidget {
  final Widget header;
  final Widget leftButton;
  final Widget rightButton;
  final Color backgroundColor;
  final MutableProperty<double> opacityProperty;

  FloatingHeader(
      {Key key,
      this.backgroundColor = Colors.white,
      this.leftButton,
      this.rightButton,
      @required this.opacityProperty, this.header})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FloatingHeaderState();
  }
}

class FloatingHeaderState extends State<FloatingHeader> with HavingSubscriptionMixin {

  double opacity =1.0;
  FloatingHeaderState(){
      }

  @override
    void initState() {
      disposeAndReset();
      opacity = widget.opacityProperty.value;
      subscription.add(widget.opacityProperty.producer.skipWhile((opacity)=>opacity==null).listen((opacity){
        setState(() {
          this.opacity = opacity;
                });
      }));
      super.initState();


      }

  @override
    void dispose() {
      subscription.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {

    return Container(
        child: Stack(
      children: <Widget>[
        new Positioned.fill(
            child: Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
                color: widget.backgroundColor,
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4.0)]),
          ),
        )),
        new SafeArea(
          left: true,
          top: true,
          bottom: false,
          child: Container(
              height: 50.0,
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              alignment: Alignment.bottomLeft,
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Container(
                    child: widget.leftButton == null
                        ? Container(
                            height: 20.0,
                            width: 20.0,
                          )
                        : widget.leftButton,
                  ),
                  Expanded(
                    child: widget.header == null
                        ? Offstage()
                        : widget.header
                  ),
                  Container(
                    child: widget.rightButton == null
                        ? Container(
                            height: 20.0,
                            width: 20.0,
                          )
                        : widget.rightButton,
                  )
                ],
              )),
        ),
      ],
    ));
  }


}
