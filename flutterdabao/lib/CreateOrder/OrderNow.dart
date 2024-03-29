import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/CustomizedMap.dart';
import 'package:flutterdabao/CreateOrder/LocationCard.dart';
import 'package:flutterdabao/CreateOrder/OrderCheckoutCard.dart';
import 'package:flutterdabao/CreateOrder/OrderOverlay.dart';
import 'package:flutterdabao/CustomWidget/Buttons/CustomizedBackButton.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Voucher.dart';

Future<OrderHolder> generateHolderFromOrder(String orderID) async {
  DocumentSnapshot snap =
      await Firestore.instance.collection("orders").document(orderID).get();

  if (snap.exists) {
    Order order = Order.fromDocument(snap);
    List<OrderItem> items = await FirebaseCollectionReactiveOnce<OrderItem>(
            Firestore.instance
                .collection(order.className)
                .document(order.uid)
                .collection("orderItems"))
        .future;

    return OrderHolder.fromOrder(order: order, items: items);
  } else {
    return null;
  }
}

class OrderNow extends StatefulWidget {
  final OrderHolder holder;

  OrderNow({Key key, @required this.holder}) : super(key: key);

  _OrderNowState createState() => _OrderNowState(holder: this.holder);
}

class _OrderNowState extends State<OrderNow> with HavingSubscriptionMixin {
  // String _address = '20 Heng Mui Keng xTerrace';

  // handle the progress through the application

  final OrderHolder holder;

  bool showMap = true;

  _OrderNowState({this.holder});

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    subscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          StreamBuilder(
            stream: holder.checkout.producer,
            builder: (context, snap) {
              return IgnorePointer(
                ignoring: snap.data == true,
                child: CustomizedMap(
                  selectedlocation: holder.deliveryLocation,
                  selectedlocationDescription:
                      holder.deliveryLocationDescription,
                ),
              );
            },
          ),
          CustomizedBackButton(
            onBack: () {
              //TOdo p3 try to flash edit button
              if (holder.checkout.value) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text("Leave?"),
                          content: Text(
                              "Your Order has not been created. Are you sure you want to leave?"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text(
                                "Leave",
                                style: FontHelper.bold(
                                    ColorHelper.dabaoOrange, 16.0),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                holder.checkout.value = false;
                              },
                            ),
                            new FlatButton(
                              child: new Text(
                                "Stay",
                                style: FontHelper.regular(Colors.black, 14.0),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          StreamBuilder<bool>(
            stream: holder.checkout.producer,
            builder: (context, snap) {
              if (snap.hasData && snap.data)
                return OrderCheckout(
                  showOverlayCallback: showOverlay,
                  holder: holder,
                );
              else
                return LocationCard(
                  showOverlayCallback: showOverlay,
                  holder: holder,
                );
            },
          ),
        ],
      ),
    );
  }

  showOverlay() {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return OrderOverlay(
            holder: holder,
            page: holder.progress,
            checkout: holder.checkout,
          );
        });
  }
}
