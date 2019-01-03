import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:rxdart/rxdart.dart';

class CompletedOverlay extends StatefulWidget {
  final Order order;
  final DabaoRoute.Route route;

  const CompletedOverlay({Key key, @required this.order, this.route})
      : super(key: key);
  _CompletedOverlayState createState() => _CompletedOverlayState();
}

class _CompletedOverlayState extends State<CompletedOverlay> {
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
              _buildHeader(widget.order),
              SizedBox(
                height: 10,
              ),
              _buildLocationDescription(widget.order),
              SizedBox(
                height: 10,
              ),
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
                      child: _buildPickUpButton(widget.order),
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

  Row _buildDeliveryPeriod(Order order) {
    return Row(
      children: <Widget>[
        StreamBuilder<DateTime>(
          stream: order.deliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            if (snap.data.day == DateTime.now().day &&
                snap.data.month == DateTime.now().month &&
                snap.data.year == DateTime.now().year) {
              return Text(
                'Today, ' + DateTimeHelper.convertDateTimeToAMPM(snap.data),
                style: FontHelper.semiBoldgrey14TextStyle,
                overflow: TextOverflow.ellipsis,
              );
            } else {
              return Container(
                child: Text(
                  snap.hasData
                      ? 'For ' +
                          DateTimeHelper.convertDateTimeToDate(snap.data) +
                          ', ' +
                          DateTimeHelper.convertDateTimeToAMPM(snap.data)
                      : "Error",
                  style: FontHelper.semiBoldgrey14TextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Flex _buildHeader(Order order) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<String>(
                stream: widget.order.foodTag,
                builder: (context, snap) {
                  if (!snap.hasData) return Offstage();
                  return Text(
                    StringHelper.upperCaseWords(snap.data),
                    style: FontHelper.semiBold16Black,
                  );
                },
              ),
              _buildDeliveryPeriod(order),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StreamBuilder<double>(
                stream: widget.order.deliveryFee,
                builder: (context, snap) {
                  if (!snap.hasData) return Offstage();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      StringHelper.doubleToPriceString(
                        snap.data,
                      ),
                      style: FontHelper.bold14Black,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
              StreamBuilder<List<OrderItem>>(
                stream: order.orderItems,
                builder: (context, snap) {
                  if (!snap.hasData) return Offstage();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      snap.hasData ? '${snap.data.length} Item(s)' : "Error",
                      style: FontHelper.medium14TextStyle,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row _buildLocationDescription(Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            right: 5,
          ),
          child: Container(
            height: 30,
            child: Image.asset("assets/icons/red_marker_icon.png"),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<String>(
              stream: order.deliveryLocationDescription,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 180),
                  child: Text(
                    snap.hasData ? '''${snap.data}''' : "Error",
                    style: FontHelper.regular14Black,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickUpButton(Order order) {
    return RaisedButton(
      elevation: 12,
      color: ColorHelper.dabaoOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Text(
          "Complete",
          style: FontHelper.semiBold14Black,
        ),
      ),
      onPressed: () async {
        showLoadingOverlay(context: context);
        var isSuccessful = await FirebaseCloudFunctions.completeOrder(
          orderID: widget.order.uid,
          acceptorID: ConfigHelper.instance.currentUserProperty.value.uid,
          completedTime: DateTimeHelper.convertDateTimeToString(DateTime.now()),
        );

        if (isSuccessful) {
          order.isSelectedProperty.value = false;
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          final snackBar = SnackBar(
              content: Text(
                  'An Error has occured. Please check your network connectivity'));
          Scaffold.of(context).showSnackBar(snackBar);
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
