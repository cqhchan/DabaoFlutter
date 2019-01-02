import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;

class CounterOfferOverlay extends StatefulWidget {
  final Order order;
  final DabaoRoute.Route route;

  const CounterOfferOverlay({Key key, @required this.order, this.route})
      : super(key: key);
  _CounterOfferOverlayState createState() => _CounterOfferOverlayState();
}

class _CounterOfferOverlayState extends State<CounterOfferOverlay> {
  double _sliderSelector = 3.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildHeader(),
              SizedBox(
                height: 10,
              ),
              _buildCurrentFee(),
              Divider(
                color: Color(0xFFEAEAEA),
              ),
              _buildSlider(),
              SizedBox(
                height: 10,
              ),
              _buildOffer(),
              Flex(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                verticalDirection: VerticalDirection.up,
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildBackButton(),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _buildConfirmButton(widget.order),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Counter-Offer Deliver Fee',
      style: FontHelper.semiBold16Black,
    );
  }

  Widget _buildCurrentFee() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: Text(
            'Current Delivery Fee',
            style: FontHelper.bold12Black,
          ),
        ),
        Expanded(
          child: StreamBuilder<double>(
            stream: widget.order.deliveryFee,
            builder: (context, snap) {
              if (!snap.hasData) return Offstage();
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    snap.hasData
                        ? StringHelper.doubleToPriceString(snap.data)
                        : "Error",
                    style: FontHelper.regular12Black,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(
                        width: 2.0,
                      ),
                      Image.asset('assets/icons/question_mark.png'),
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildSlider() {
    return Column(
      children: <Widget>[
        Container(
          color: Color(0xFFF3F3F3),
          child: Slider(
            activeColor: Color(0xFFBCE0FD),
            inactiveColor: Colors.white,
            divisions: 6,
            max: 4.5,
            min: 1.5,
            value: _sliderSelector,
            onChanged: (data) {
              setState(() {
                _sliderSelector = data;
              });
            },
          ),
        ),
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(1.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(2.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(2.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(3.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(3.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(4.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(4.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
          ],
        )
      ],
    );
  }

  Widget _buildOffer() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: Text(
            'Your Offer',
            style: FontHelper.bold12Black,
          ),
        ),
        Expanded(
            child: Text(
          StringHelper.doubleToPriceString(_sliderSelector),
          style: FontHelper.regular12Black,
          textAlign: TextAlign.right,
        )),
      ],
    );
  }

  Widget _buildConfirmButton(Order order) {
    return StreamBuilder(
      stream: order.mode,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        switch (snap.data) {
          case OrderMode.asap:
            return RaisedButton(
              elevation: 12,
              color: Color(0xFF959DAD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Center(
                child: Text(
                  "Confirm",
                  style: FontHelper.semiBold14White,
                ),
              ),
              onPressed: () async {
                //TODO: blur this widget
              },
            );
          case OrderMode.scheduled:
            return RaisedButton(
              elevation: 12,
              color: ColorHelper.dabaoOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  "Complete",
                  style: FontHelper.semiBold14White,
                ),
              ),
              onPressed: () async {
                //TODO: blur this widget
              },
            );
            break;
          default:
            return Offstage();
        }
      },
    );
  }

  Widget _buildBackButton() {
    return RaisedButton(
      elevation: 12,
      color: ColorHelper.dabaoOffWhiteF5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Text(
          "Back",
          style: FontHelper.semiBold14Black,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
