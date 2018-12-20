import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutterdabao/CreateOrder/OverlayPages/DescriptionInputPage.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingGoogleMapPlaces.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/TimePicker/TimePickerEditor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class OrderCheckout extends StatefulWidget {
  final OrderHolder holder;
  final VoidCallback showOverlayCallback;
  const OrderCheckout(
      {Key key, @required this.showOverlayCallback, @required this.holder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OrderCheckoutState();
  }
}

class _OrderCheckoutState extends State<OrderCheckout>
    with HavingGoogleMapPlaces, HavingSubscriptionMixin {
  @override
  void initState() {
    super.initState();
    disposeAndReset();
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          //Top Bar
          StreamBuilder<OrderMode>(
            stream: widget.holder.mode.producer,
            builder: (context, snap) {
              switch (snap.data) {
                case OrderMode.asap:
                  return topSwitchBar(
                      title: "ASAP Delivery",
                      subTitle: "Find you a Dabaoer as soon as possible",
                      image: Image(
                        image: AssetImage("assets/icons/run.png"),
                        color: ColorHelper.dabaoOrange,
                      ),
                      onTap: _showSelectionSheet);

                case OrderMode.scheduled:
                  return topSwitchBar(
                      title: "Scheduled Delivery",
                      subTitle: "Order Delivered Within Fixed Time Period",
                      image: Image(
                        image: AssetImage("assets/icons/stand.png"),
                        color: ColorHelper.dabaoOrange,
                      ),
                      onTap: _showSelectionSheet);

                default:
                  return Container();
              }
            },
          ),
          //Bottom Card
          Container(
            alignment: Alignment(0.0, -1.0),
            padding: EdgeInsets.fromLTRB(23.0, 15.0, 23.0, 0.0),
            margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 35.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0.0, 1.0),
                    color: Colors.grey,
                    blurRadius: 5.0,
                  )
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildHeader(),
                SizedBox(
                  height: 10.0,
                ),
                buildSelectedlocationWidget(),
                Line(
                  margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                ),
                buildTimeColumns(),
                buildDescriptionTextField(),
                Line(),
                buildPaymentMode(),
                Container(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildEditButton(),
                      ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 110),
                          child: Line(
                            margin: EdgeInsets.only(top: 10.0),
                            vertical: true,
                          )),
                      buildOrderButton(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditButton() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 100, minWidth: 90),
      child: Container(
        padding: EdgeInsets.only(right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder(
                    stream: widget.holder.numberOfItems.producer,
                    builder: (context, snap) {
                      return Text(snap.hasData ? snap.data.toString() : "0",
                          style: FontHelper.semiBold(Colors.black, 24.0));
                    },
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5.0, top: 8.0),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text("Items",
                            style: FontHelper.regular(
                                ColorHelper.dabaoOffBlack4A, 12.0))),
                  ),
                ],
              ),
            ),
            RaisedButton(
              elevation: 0.0,
              highlightElevation: 0.0,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/icons/shopping_cart_icon.png'),
                  SizedBox(
                    height: 40.0,
                    width: 5.0,
                  ),
                  FittedBox(
                    child: Text(
                      'Edit',
                      textAlign: TextAlign.center,
                      style: FontHelper.bold(Colors.black, 12.0),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                widget.showOverlayCallback();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: ColorHelper.dabaoOrange)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderButton() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 10.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder(
                    stream: widget.holder.finalPrice.producer,
                    builder: (context, snap) {
                      return Text(
                          StringHelper.doubleToPriceString(
                              snap.hasData ? snap.data : 0.0),
                          style: FontHelper.semiBold(Colors.black, 24.0));
                    },
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5.0, top: 0.0),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text("Total\nEst.",
                            style: FontHelper.regular(
                                ColorHelper.dabaoOffBlack4A, 12.0))),
                  ),
                ],
              ),
            ),
            FractionallySizedBox(
              widthFactor: 1.0,
              child: RaisedButton(
                elevation: 0.0,
                highlightElevation: 0.0,
                color: ColorHelper.dabaoOrange,
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                child: Container(
                  height: 40.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Create Order',
                        textAlign: TextAlign.center,
                        style: FontHelper.bold(Colors.black, 14.0),
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  if (Order.isValid(widget.holder)) {
                    Order.createOrder(widget.holder);
                    Navigator.of(context).pop();
                  } else {
                    print("Failed");
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: ColorHelper.dabaoOrange)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDescriptionTextField() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(FadeRoute(
            widget: MessageInputPage(
          defaultText: widget.holder.message.value,
          textCallBack: (message) {
            widget.holder.message.value = message;
          },
        )));
      },
      child: Container(
          margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
          padding: EdgeInsets.all(10.0),
          height: 80,
          decoration: BoxDecoration(
              border: Border.all(color: ColorHelper.dabaoOffGrey70, width: 0.2),
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5.0)),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: StreamBuilder<String>(
                      stream: widget.holder.message.producer,
                      builder: (context, snap) {
                        if (!snap.hasData || snap.data.isEmpty) {
                          return Text(
                            "Message for Dabaoer\n E.g. Am open to food from elsewhere too, message me!",
                            style: FontHelper.medium(
                                ColorHelper.dabaoOffGrey70, 12.0),
                          );
                        } else {
                          return Text(
                            snap.data,
                            style: FontHelper.medium(Colors.black, 12.0),
                          );
                        }
                      }),
                ),
              ),
            ],
          )),
    );
  }

  StreamBuilder<OrderMode> buildTimeColumns() {
    return StreamBuilder<OrderMode>(
        stream: widget.holder.mode.producer,
        builder: (context, snap) {
          switch (snap.data) {
            case OrderMode.asap:
              return StreamBuilder<DateTime>(
                stream: widget.holder.endDeliveryTime.producer,
                builder: (context, snap) {
                  return buildTime(
                      title: "Cut-Off Time",
                      time: !snap.hasData
                          ? "Optional"
                          : DateTimeHelper.convertTimeToDisplayString(
                              snap.data));
                },
              );

            case OrderMode.scheduled:
              return GestureDetector(
                onTap: () {
                  showtimeCreator(
                    startTime: widget.holder.startDeliveryTime.value,
                    endTime: widget.holder.endDeliveryTime.value,
                    context: context,
                    onCompleteCallBack: (DateTime start, DateTime end) {
                      widget.holder.startDeliveryTime.value = start;
                      widget.holder.endDeliveryTime.value = end;
                    },
                  );
                },
                child: Column(
                  children: <Widget>[
                    StreamBuilder<DateTime>(
                      stream: widget.holder.startDeliveryTime.producer,
                      builder: (context, snap) {
                        return buildTime(
                            title: "Deliver From",
                            time: !snap.hasData
                                ? "Select Time"
                                : DateTimeHelper.convertTimeToDisplayString(
                                    snap.data));
                      },
                    ),
                    StreamBuilder<DateTime>(
                      stream: widget.holder.endDeliveryTime.producer,
                      builder: (context, snap) {
                        return buildTime(
                            title: "Deliver By",
                            time: !snap.hasData
                                ? "Select Time"
                                : DateTimeHelper.convertTimeToDisplayString(
                                    snap.data));
                      },
                    ),
                  ],
                ),
              );

            default:
              return Container();
          }
        });
  }

  Widget buildPaymentMode() {
    return Column(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(left: 2.0, top: 10.0, bottom: 10.0, right: 2.0),
          child: Row(
            children: <Widget>[
              Text(
                "Payment",
                style: FontHelper.bold(Colors.black, 14.0),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Cash",
                        style: FontHelper.medium(
                            ColorHelper.dabaoOffBlack4A, 14.0),
                      )))
            ],
          ),
        ),
        Line()
      ],
    );
  }

  Widget buildTime({String title, String time}) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 2.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.access_time),
              Container(
                margin: EdgeInsets.only(left: 8.0),
                child: Text(
                  title,
                  style: FontHelper.bold(Colors.black, 14.0),
                ),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        time,
                        style: FontHelper.medium(
                            ColorHelper.dabaoOffBlack4A, 14.0),
                      )))
            ],
          ),
        ),
        Line()
      ],
    );
  }

  Widget buildSelectedlocationWidget() {
    return GestureDetector(
      onTap: _handleTapLocation,
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/icons/pin.png',
            fit: BoxFit.fill,
            width: 18.0,
            height: 18.0,
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
              child: StreamBuilder<String>(
            stream: widget.holder.deliveryLocationDescription.producer,
            builder: (context, addressSnap) {
              if (addressSnap.connectionState == ConnectionState.waiting ||
                  !addressSnap.hasData) {
                return Text(
                  "Select Location",
                  style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
                );
              } else {
                return Text(
                  addressSnap.data,
                  style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
                  overflow: TextOverflow.ellipsis,
                );
              }
            },
          )),
        ],
      ),
    );
  }

  Future<void> _handleTapLocation() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.fullscreen,
      language: "en",
      components: [Component(Component.country, "sg")],
    );

    if (p != null) {
      LatLng newLocation = await getLatLng(p);
      widget.holder.deliveryLocation.producer.add(newLocation);
      widget.holder.deliveryLocationDescription.producer.add(p.description);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    SnackBar(content: Text(response.errorMessage));
  }

  Text buildHeader() {
    return Text(
      'Deliver to...',
      style: FontHelper.semiBold16(ColorHelper.dabaoOffBlack4A),
    );
  }

  Widget topSwitchBar(
      {String title, String subTitle, Widget image, VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment(0.0, -1.0),
        padding: EdgeInsets.fromLTRB(15.0, 4.0, 23.0, 0.0),
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 12.0),
        height: 54.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                offset: Offset(0.0, 1.0),
                color: Colors.grey,
                blurRadius: 5.0,
              )
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  color: ColorHelper.dabaoOffGreyD8,
                ),
                width: 50.0,
                height: 4.0,
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 8.0),
                    child: image,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: FontHelper.bold(Colors.black, 14.0),
                        ),
                        Expanded(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                subTitle,
                                style: FontHelper.regular(Colors.black, 12.0),
                              )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSelectionSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SafeArea(
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  topSwitchBar(
                      onTap: () {
                        widget.holder.mode.value = OrderMode.asap;
                        Navigator.of(context).pop();
                      },
                      title: "ASAP Delivery",
                      subTitle: "Find you a Dabaoer as soon as possible",
                      image: Image(
                        image: AssetImage("assets/icons/run.png"),
                        color: ColorHelper.dabaoOrange,
                      )),
                  topSwitchBar(
                      onTap: () {
                        widget.holder.mode.value = OrderMode.scheduled;
                        Navigator.of(context).pop();
                      },
                      title: "Scheduled Delivery",
                      subTitle: "Order Delivered Within Fixed Time Period",
                      image: Image(
                        image: AssetImage("assets/icons/stand.png"),
                        color: ColorHelper.dabaoOrange,
                      )),
                ],
              ),
            ),
          );
        });
  }
}
