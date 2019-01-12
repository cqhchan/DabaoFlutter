import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
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
import 'package:flutterdabao/Model/User.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';

class CompleteOverlay extends StatefulWidget {
  final Order order;
  final DabaoRoute.Route route;

  const CompleteOverlay({Key key, @required this.order, this.route})
      : super(key: key);
  _CompleteOverlayState createState() => _CompleteOverlayState();
}

class _CompleteOverlayState extends State<CompleteOverlay>
    with HavingSubscriptionMixin {
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  @override
  void initState() {
    super.initState();

    listOfOrderItems = widget.order.orderItem;
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Builder(
        builder: (context) => Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: _buildTitle(),
                        ),
                        Container(
                          child: _buildHeader(widget.order),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: _buildLocationDescription(widget.order),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: StreamBuilder<User>(
                            stream: widget.order.creator.map(
                                (id) => id == null ? null : User.fromUID(id)),
                            builder: (BuildContext context, snapshot) {
                              return _buildUser(snapshot.data);
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: _buildOrderCode(widget.order),
                        ),
                        Container(
                          child: Flex(
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
                                  child: _buildPickUpButton(widget.order, context),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Row(
            children: <Widget>[
              Text(
                'Complete Delivery',
                style: FontHelper.semiBold16Black,
              ),
              SizedBox(
                width: 5,
              ),
              Image.asset('assets/icons/happy.png')
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Line(),
        )
      ],
    );
  }

  Widget _buildDeliveryPeriod(Order order) {
    return Row(
      children: <Widget>[
        StreamBuilder<DateTime>(
          stream: order.deliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            return Text(
                DateTimeHelper.convertTimeToDisplayString(snap.data),
                style: FontHelper.semiBoldgrey14TextStyle,
                overflow: TextOverflow.ellipsis,
              );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(Order order) {
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
                stream: listOfOrderItems.producer,
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

  Widget _buildLocationDescription(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
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
            Text(
              "Deliver To:",
              style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                textAlign: TextAlign.right,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUser(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.asset('assets/icons/person.png'),
            SizedBox(
              width: 10,
            ),
            Text(
              "Dabaoee:",
              style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        user == null
            ? Offstage()
            : Row(
                children: <Widget>[
                  StreamBuilder<String>(
                    stream: user.thumbnailImage,
                    builder: (context, snap) {
                      if (!snap.hasData || snap.data == null) return Offstage();

                      return FittedBox(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: SizedBox(
                            height: 35,
                            width: 35,
                            child: CachedNetworkImage(
                              imageUrl: snap.data,
                              placeholder: GlowingProgressIndicator(
                                child: Icon(
                                  Icons.account_circle,
                                  size: 35,
                                ),
                              ),
                              errorWidget: Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  StreamBuilder<String>(
                    stream: user.name,
                    builder: (context, snap) {
                      if (snap.data == null) return Offstage();
                      return Container(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          snap.data,
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

  Widget _buildPickUpButton(Order order, BuildContext context) {
    return RaisedButton(
      elevation: 12,
      color: ColorHelper.dabaoOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Text(
          "Confirm",
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

  Widget _buildOrderCode(Order order) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Order Code:",
            style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
            textAlign: TextAlign.center,
          ),
          Text(
            order.uid,
            style: FontHelper.regular14Black,
            textAlign: TextAlign.center,
          ),
        ]);
  }
}
