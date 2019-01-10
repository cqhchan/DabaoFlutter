// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutterdabao/Chat/ChatNavigationButton.dart';
// import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
// import 'package:flutterdabao/CustomWidget/Line.dart';
// import 'package:flutterdabao/ExtraProperties/HavingGoogleMaps.dart';
// import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
// import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
// import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
// import 'package:flutterdabao/HelperClasses/FontHelper.dart';
// import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
// import 'package:flutterdabao/HelperClasses/StringHelper.dart';
// import 'package:flutterdabao/Model/Order.dart';
// import 'package:flutterdabao/Model/OrderItem.dart';
// import 'package:flutterdabao/Model/User.dart';
// import 'package:flutterdabao/Profile/ViewProfile.dart';
// import 'package:flutterdabao/ViewOrdersTabPages/CancelOverlay.dart';
// import 'package:flutterdabao/ViewOrdersTabPages/CompleteOverlay.dart';
// import 'package:flutterdabao/ViewOrdersTabPages/CompletedOverlay.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:progress_indicators/progress_indicators.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ConfirmedSummary extends StatefulWidget {
//   final Order order;

//   ConfirmedSummary({Key key, this.order}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return _ConfirmedSummaryState();
//   }
// }

// class _ConfirmedSummaryState extends State<ConfirmedSummary>
//     with HavingSubscriptionMixin {
//   MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

//   @override
//   void initState() {
//     super.initState();

//     listOfOrderItems = widget.order.orderItem;
//   }

//   @override
//   void dispose() {
//     disposeAndReset();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorHelper.dabaoOffWhiteF5,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: Text('Your Order', style: FontHelper.header3TextStyle),
//         actions: <Widget>[
//           ChatNavigationButton(),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.fromLTRB(15.0, 20.0, 20.0, 20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Container(
//               padding: EdgeInsets.only(bottom: 20.0),
//               child: _DeliveryTime(order: widget.order),
//             ),
//             Container(
//               padding: EdgeInsets.only(bottom: 20.0),
//               child: _DeliveryLocation(
//                 order: widget.order,
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.only(bottom: 20.0),
//               child: StreamBuilder<User>(
//                 stream: widget.order.creator
//                     .map((id) => id == null ? null : User.fromUID(id)),
//                 builder: (BuildContext context, snapshot) {
//                   return buildUser(snapshot.data);
//                 },
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.only(bottom: 20.0),
//               child: _BuildOrderCode(order: widget.order),
//             ),
//             Container(
//               padding: EdgeInsets.only(bottom: 5.0),
//               child: Line(),
//             ),
//             _FoodTagAndTotalItems(
//               order: widget.order,
//             ),
//             Container(
//               padding: EdgeInsets.only(bottom: 5.0),
//               child: _OrderItems(
//                 editable: true,
//                 order: widget.order,
//                 listOfOrderItems: listOfOrderItems,
//               ),
//             ),
//             _SubTotal(order: widget.order),
//             Container(
//               padding: EdgeInsets.only(top: 5.0),
//               child: Line(),
//             ),
//             _DeliveryFee(order: widget.order),
//             _Promo(
//               order: widget.order,
//             ),
//             Container(
//               padding: EdgeInsets.only(top: 5.0),
//               child: Line(),
//             ),
//             buildFinalDeliveryFee(widget.order),
//             Container(
//               padding: EdgeInsets.only(top: 5.0),
//               child: _Button(order: widget.order),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildFinalDeliveryFee(Order order) {
//     return StreamBuilder<double>(
//       stream: order.deliveryFee.map((deliveryFee) {
//         double deliveryFeeDiscount = order.deliveryFeeDiscount.value == null
//             ? 0.0
//             : order.deliveryFeeDiscount.value;
//         double totalPrice = deliveryFee - deliveryFeeDiscount < 0
//             ? 0
//             : deliveryFee - deliveryFeeDiscount;
//         return totalPrice;
//       }),
//       builder: (BuildContext context, snapshot) {
//         if (!snapshot.hasData || snapshot.data == null) return Offstage();
//         return Container(
//           padding: EdgeInsets.only(top: 5.0),
//           child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Text("Delivery Fee To Collect", style: FontHelper.bold14Black),
//                 Text(StringHelper.doubleToPriceString(snapshot.data),
//                     style: FontHelper.bold14Black),
//               ]),
//         );
//       },
//     );
//   }

//   Widget buildUser(User user) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         Text(
//           "Dabaoee",
//           style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
//           textAlign: TextAlign.center,
//         ),
//         user == null
//             ? Offstage()
//             : Row(
//                 children: <Widget>[
//                   StreamBuilder<User>(
//                       stream: widget.order.creator
//                           .map((id) => id == null ? null : User.fromUID(id)),
//                       builder: (context, snapshot) {
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ViewProfile(
//                                         currentUser: snapshot,
//                                       ),
//                                 ));
//                           },
//                           child: Row(
//                             children: <Widget>[
//                               StreamBuilder<String>(
//                                 stream: user.thumbnailImage,
//                                 builder: (context, snap) {
//                                   if (!snap.hasData || snap.data == null)
//                                     return Offstage();
//                                   return FittedBox(
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(30.0),
//                                       child: SizedBox(
//                                         height: 35,
//                                         width: 35,
//                                         child: CachedNetworkImage(
//                                           imageUrl: snap.data,
//                                           placeholder: GlowingProgressIndicator(
//                                             child: Icon(
//                                               Icons.account_circle,
//                                               size: 35,
//                                             ),
//                                           ),
//                                           errorWidget: Icon(Icons.error),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               StreamBuilder<String>(
//                                 stream: user.name,
//                                 builder: (context, snap) {
//                                   if (snap.data == null) return Offstage();
//                                   return Container(
//                                     padding: EdgeInsets.only(left: 10.0),
//                                     child: Text(
//                                       snap.data,
//                                       style: FontHelper.regular14Black,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                   StreamBuilder<String>(
//                     stream: user.handPhone,
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) return Offstage();
//                       return GestureDetector(
//                           onTap: () {
//                             _makePhoneCall('tel:' + snapshot.data);
//                           },
//                           child: Padding(
//                             padding: EdgeInsets.only(left: 10.0),
//                             child: Icon(
//                               Icons.phone,
//                               color: Colors.black,
//                             ),
//                           ));
//                     },
//                   ),
//                 ],
//               ),
//       ],
//     );
//   }

//   Future<void> _makePhoneCall(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   Widget orderStatus(Order order) {
//     return Align(
//       alignment: Alignment.topLeft,
//       child: StreamBuilder<String>(
//         stream: order.status,
//         builder: (BuildContext context, snapshot) {
//           if (!snapshot.hasData || snapshot.data == null) {
//             return Offstage();
//           }

//           switch (snapshot.data) {
//             case orderStatus_Accepted:
//               return Container(
//                 height: 19,
//                 width: 60,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5.0),
//                   color: ColorHelper.dabaoOrange,
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Enroute",
//                     style: FontHelper.semiBold12Black,
//                   ),
//                 ),
//               );
//             case orderStatus_Requested:
//               return Container(
//                 height: 19,
//                 width: 60,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5.0),
//                     color: Color.fromRGBO(0x95, 0x9D, 0xAD, 1.0)),
//                 child: Center(
//                   child: Text("Pending",
//                       style: FontHelper.semiBold(Colors.white, 12.0)),
//                 ),
//               );
//             case orderStatus_Completed:
//               return Container(
//                 padding: EdgeInsets.only(left: 2.0),
//                 height: 19,
//                 width: 60,
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text("Delivered",
//                       style: FontHelper.semiBold(
//                           ColorHelper.dabaoOffGreyD3, 12.0)),
//                 ),
//               );
//             default:
//               return Offstage();
//           }
//         },
//       ),
//     );
//   }
// }

// class _DeliveryTime extends StatelessWidget {
//   final Order order;

//   const _DeliveryTime({Key key, this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<String>(
//       stream: order.status.switchMap((status) {
//         switch (status) {
//           case orderStatus_Accepted:
//             return order.deliveryTime.map((date) => date == null
//                 ? "Error"
//                 : DateTimeHelper.convertTimeToDisplayString(date));

//           case orderStatus_Completed:
//             return order.completedTime.map((date) => date == null
//                 ? "Error"
//                 : DateTimeHelper.convertTimeToDisplayString(date));

//           case orderStatus_Requested:
//             return order.mode.switchMap((mode) {
//               switch (mode) {
//                 case OrderMode.asap:
//                   return BehaviorSubject(seedValue: "ASAP");
//                 case OrderMode.scheduled:
//                   return Observable.combineLatest2(
//                       order.startDeliveryTime, order.endDeliveryTime,
//                       (start, end) {
//                     if (start == null || end == null) return "Error";

//                     return DateTimeHelper.convertDoubleTimeToDisplayString(
//                         start, end);
//                   });
//               }
//             });

//           default:
//             return BehaviorSubject(seedValue: null);
//         }
//       }),
//       builder: (BuildContext context, snapshot) {
//         if (!snapshot.hasData || snapshot.data == null) {
//           return Offstage();
//         }
//         return Text(
//           snapshot.data,
//           style: FontHelper.regular(Colors.black, 14.0),
//           textAlign: TextAlign.center,
//         );
//       },
//     );
//   }
// }

// class _DeliveryLocation extends StatelessWidget {
//   final Order order;

//   const _DeliveryLocation({Key key, this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           "Deliver To:",
//           style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
//           textAlign: TextAlign.center,
//         ),
//         Row(
//           children: <Widget>[
//             ConstrainedBox(
//               child: StreamBuilder<String>(
//                 stream: order.deliveryLocationDescription,
//                 builder: (BuildContext context, snapshot) {
//                   if (!snapshot.hasData || snapshot.data == null) {
//                     return Offstage();
//                   }
//                   return Text(
//                     snapshot.data,
//                     style: FontHelper.regular(Colors.black, 14.0),
//                     textAlign: TextAlign.right,
//                   );
//                 },
//               ),
//               constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width / 2),
//             ),
//             Container(
//               margin: EdgeInsets.only(left: 10.0),
//               child: GestureDetector(
//                   child: Image.asset('assets/icons/google-maps.png'),
//                   onTap: () {
//                     LatLng temp = LatLng(order.deliveryLocation.value.latitude,
//                         order.deliveryLocation.value.longitude);
//                     launchMaps(temp);
//                   }),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _BuildOrderCode extends StatelessWidget {
//   final Order order;

//   const _BuildOrderCode({Key key, this.order}) : super(key: key);

//   Widget buildOrderID(Order order) {
//     return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Text(
//             "Order Code:",
//             style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 14.0),
//             textAlign: TextAlign.center,
//           ),
//           Text(
//             order.uid,
//             style: FontHelper.regular14Black,
//             textAlign: TextAlign.center,
//           ),
//         ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return buildOrderID(order);
//   }
// }

// class _OrderItems extends StatefulWidget {
//   final bool editable;
//   final Order order;
//   final MutableProperty<List<OrderItem>> listOfOrderItems;

//   const _OrderItems(
//       {Key key, this.order, this.listOfOrderItems, this.editable = false})
//       : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _OrderItemsState();
//   }
// }

// class _OrderItemsState extends State<_OrderItems> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         buildOrderItemsList(),
//       ],
//     );
//   }

//   Widget buildOrderItemsList() {
//     return Container(
//       margin: EdgeInsets.only(top: 10.0),
//       child: StreamBuilder<List<OrderItem>>(
//         stream: widget.listOfOrderItems.producer,
//         builder: (context, snap) {
//           List<Widget> listOfWidget = List();
//           if (!snap.hasData || snap.data == null)
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           snap.data.forEach(
//               (orderItem) => listOfWidget.add(buildOrderItemCell(orderItem)));
//           return Column(
//             children: listOfWidget,
//           );
//         },
//       ),
//     );
//   }

//   Widget buildOrderItemCell(OrderItem orderItem) {
//     if (!widget.editable) {
//       return ConstrainedBox(
//         constraints: BoxConstraints(minHeight: 45),
//         child: Container(
//           padding: EdgeInsets.only(top: 5, left: 5, right: 5),
//           color: Colors.white,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   width: 30.0,
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       "${orderItem.quantity.value} x",
//                       style: FontHelper.semiBold12Black,
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text(
//                       orderItem.name.value,
//                       style: FontHelper.semiBold12Black,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       orderItem.description.value,
//                       style:
//                           FontHelper.semiBold(ColorHelper.dabaoOffBlack4A, 10),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: 10.0,
//               ),
//               Align(
//                 alignment: Alignment.topRight,
//                 child: Text(
//                     "Max: ${StringHelper.doubleToPriceString(orderItem.price.value)}",
//                     style: FontHelper.regular12Black),
//               )
//             ],
//           ),
//         ),
//       );
//     } else {
//       return GestureDetector(
//         onTap: () {
//           orderItem.updateBought(widget.order, !orderItem.isBought.value);
//         },
//         child: ConstrainedBox(
//           constraints: BoxConstraints(minHeight: 45),
//           child: Container(
//             padding: EdgeInsets.only(top: 5, left: 5, right: 5),
//             color: Colors.white,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   width: 30.0,
//                   margin: EdgeInsets.only(top: 5),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: StreamBuilder<bool>(
//                       stream: orderItem.isBought,
//                       builder: (BuildContext context, snapshot) {
//                         if (!snapshot.hasData ||
//                             snapshot.data == null ||
//                             !snapshot.data)
//                           return Container(
//                             height: 18,
//                             width: 18,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: ColorHelper.dabaoOrange,
//                                 width: 1.5,
//                               ),
//                             ),
//                           );
//                         else
//                           return Icon(
//                             Icons.check_circle,
//                             color: ColorHelper.dabaoOrange,
//                             size: 18,
//                           );
//                       },
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         orderItem.name.value,
//                         style: FontHelper.semiBold12Black,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         orderItem.description.value,
//                         style: FontHelper.semiBold(
//                             ColorHelper.dabaoOffBlack4A, 10),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   width: 10.0,
//                 ),
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: Text(
//                       "Max: ${StringHelper.doubleToPriceString(orderItem.price.value)}",
//                       style: FontHelper.regular12Black),
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//   }
// }

// class _DeliveryFee extends StatelessWidget {
//   final Order order;

//   const _DeliveryFee({Key key, this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return buildDeliveryFee();
//   }

//   Widget buildDeliveryFee() {
//     return StreamBuilder<double>(
//       stream: order.deliveryFee,
//       builder: (context, snap) {
//         if (!snap.hasData || snap.data == null) return Offstage();

//         return Container(
//           margin: EdgeInsets.only(top: 10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text("Delivery Fee Selected", style: FontHelper.regular14Black),
//               Text(StringHelper.doubleToPriceString(snap.data),
//                   style: FontHelper.regular12Black),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _SubTotal extends StatelessWidget {
//   final Order order;

//   const _SubTotal({Key key, this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return buildDeliveryFee();
//   }

//   Widget buildDeliveryFee() {
//     return StreamBuilder<double>(
//       stream: order.orderItem.producer.map((orderItems) {
//         return orderItems
//             .map(
//                 (orderItem) => orderItem.price.value * orderItem.quantity.value)
//             .reduce((lhs, rhs) => lhs + rhs);
//       }),
//       builder: (context, snap) {
//         if (!snap.hasData) return Offstage();

//         return Container(
//           margin: EdgeInsets.only(top: 10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text("SubTotal (Food Items)", style: FontHelper.bold14Black),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text("max.", style: FontHelper.regular12Black),
//                   SizedBox(
//                     width: 5.0,
//                   ),
//                   Text(
//                       snap.data == null
//                           ? "\$0.00"
//                           : StringHelper.doubleToPriceString(snap.data),
//                       style: FontHelper.bold14Black),
//                 ],
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _Promo extends StatelessWidget {
//   final Order order;

//   const _Promo({Key key, this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return buildPromo();
//   }

//   Widget buildPromo() {
//     return StreamBuilder<double>(
//       stream: order.deliveryFeeDiscount,
//       builder: (context, snap) {
//         return Container(
//           margin: EdgeInsets.only(top: 10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text("Promo Code", style: FontHelper.regular14Black),
//               Text(
//                   "- " +
//                       StringHelper.doubleToPriceString(
//                           !snap.hasData || snap.data == null ? 0.0 : snap.data),
//                   style: FontHelper.regular12Black),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _FoodTagAndTotalItems extends StatelessWidget {
//   final Order order;

//   const _FoodTagAndTotalItems({Key key, this.order}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return buildFoodTagHeader();
//   }

//   Widget buildFoodTagHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         StreamBuilder<String>(
//           stream: order.foodTag,
//           builder: (context, snap) {
//             if (!snap.hasData || snap.data == null) return Offstage();
//             return Row(
//               children: <Widget>[
//                 Text("Pick Up from:  ",
//                     style:
//                         FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 12)),
//                 Text(
//                   StringHelper.upperCaseWords(snap.data),
//                   style: FontHelper.regular14Black,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             );
//           },
//         ),
//         StreamBuilder<int>(
//             stream: order.orderItem.producer.map((orderItems) =>
//                 orderItems == null
//                     ? null
//                     : orderItems.length == 0
//                         ? 0
//                         : orderItems
//                             .map((o) => o.quantity.value)
//                             .reduce((lhs, rhs) => lhs + rhs)),
//             builder: (context, snap) {
//               if (!snap.hasData || snap.data == null) return Offstage();

//               return Text(
//                 "${snap.data} item(s)",
//                 style: FontHelper.regular14Black,
//               );
//             }),
//       ],
//     );
//   }
// }

// class _Button extends StatefulWidget {
//   final Order order;

//   const _Button({Key key, this.order}) : super(key: key);
//   @override
//   _ButtonState createState() {
//     return new _ButtonState();
//   }
// }

// class _ButtonState extends State<_Button> {
//   @override
//   Widget build(BuildContext context) {
//     return Flex(
//       direction: Axis.horizontal,
//       children: <Widget>[
//         Expanded(
//           child: OutlineButton(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10.0)),
//             textColor: Colors.black,
//             child: Text(
//               'Cancel Delivery',
//               textAlign: TextAlign.center,
//             ),
//             onPressed: () {
//               showCancel(widget.order);
//             },
//           ),
//         ),
//         SizedBox(
//           width: 10,
//         ),
//         Expanded(
//           flex: 2,
//           child: RaisedButton(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10.0)),
//             textColor: Colors.black,
//             color: ColorHelper.dabaoOrange,
//             child: Text(
//               'Complete Delivery',
//               textAlign: TextAlign.center,
//             ),
//             onPressed: () {
//               showComplete(widget.order);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   showCancel(Order order) {
//     showHalfBottomSheet(
//         context: context,
//         builder: (builder) {
//           return CancelOverlay(
//             order: order,
//             // route: widget.route,
//           );
//         });
//   }

//   showComplete(Order order) {
//     showHalfBottomSheet(
//         context: context,
//         builder: (builder) {
//           return CompleteOverlay(
//             order: order,
//             // route: widget.route,
//           );
//         });
//   }
// }
