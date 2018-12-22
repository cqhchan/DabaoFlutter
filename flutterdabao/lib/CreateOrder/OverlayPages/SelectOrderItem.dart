import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Buttons/ArrowButton.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/CustomWidget/ScaleGestureDetector.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/OrderItems/OrderItemEditor.dart';
import 'package:flutterdabao/OrderItems/OrderItemSummary.dart';
import 'package:intl/intl.dart';

typedef AddOrderItemCallBack = void Function(OrderItem);

class SelectOrderItem extends StatefulWidget {
  final OrderHolder holder;
  final VoidCallback nextPage;

  SelectOrderItem({
    Key key,
    @required this.holder,
    @required this.nextPage,
  }) : super(key: key);

  @override
  State<SelectOrderItem> createState() {
    return _SelectOrderItemState();
  }
}

class _SelectOrderItemState extends State<SelectOrderItem>
    with HavingSubscriptionMixin {
  static final MutableProperty<List<OrderItem>> suggestedOrderItems =
      MutableProperty(List());

  static String lastSearchFoodTag;

  @override
  void initState() {
    super.initState();

    subscription.add(widget.holder.foodTag.producer.listen((foodTag) async {
      if (lastSearchFoodTag == null || lastSearchFoodTag != foodTag)
        FirebaseCloudFunctions.fetchOrderItemForFoodTag(foodTagTitle: foodTag)
            .then((orderItem) {
          suggestedOrderItems.value = orderItem;
          lastSearchFoodTag = foodTag;
        });
    }));
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  //3 portions Suggested Orders
  //Your Orders
  // Checkout Button
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorHelper.dabaoOffWhiteF5,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              //Suggested orders
              Container(
                  padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                  child: suggestedOrders()),

              Container(
                  padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 30.0),
                  child: OrderItemSummary(
                    holders: widget.holder,
                  )),

              StreamBuilder<List<OrderItemHolder>>(
                stream: widget.holder.orderItems.producer,
                builder: (context, snap) {
                  if (snap.hasData && snap.data.length > 0) {
                    return Container(
                      padding: EdgeInsets.only(
                          left: 30.0, right: 30.0, bottom: 20.0),
                      child: ArrowButton(
                        title: "Go to Checkout",
                        onPressedCallback: () {
                          widget.nextPage();
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget suggestedOrders() {
    return StreamBuilder<List<OrderItem>>(
      stream: suggestedOrderItems.producer,
      builder: (context, snap) {
        //return an empty container if no suggested Orders
        if (!snap.hasData ) return CircularProgressIndicator();
        if (snap.data.isEmpty) return Container();
        
        List<Widget> suggestOrdersWidget = List();

        suggestOrdersWidget.add(Text(
          "Suggested Orders",
          style: FontHelper.medium(ColorHelper.dabaoOffBlack4A, 14.0),
        ));

        snap.data
            .map((orderItem) => _OrderItemSuggestedCell(
                  onAddTapped: (OrderItem item) {
                    //Show Order Creator page
                    showOrderItemCreator(
                        context: context,
                        creationTemplate: item,
                        foodTagTitle: widget.holder.foodTag.value,
                        onCompleteCallback: (OrderItemHolder orderItemHolder) {
                          widget.holder.orderItems.value.add(orderItemHolder);
                          widget.holder.orderItems.onAdd();
                        });
                  },
                  orderItem: orderItem,
                ))
            .forEach((cell) => suggestOrdersWidget.add(cell));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: suggestOrdersWidget,
        );
      },
    );
  }
}

class _OrderItemSuggestedCell extends StatelessWidget {
  final OrderItem orderItem;
  final AddOrderItemCallBack onAddTapped;
  final NumberFormat formatCurrency = new NumberFormat.simpleCurrency();

  _OrderItemSuggestedCell({Key key, @required this.orderItem, this.onAddTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.0,
      margin: EdgeInsets.only(top: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Row(
                children: <Widget>[
                  //menu Icon
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          padding: EdgeInsets.only(bottom: 3.0, left: 4.0),
                          child: Image.asset(
                              'assets/icons/icon_menu_orange.png'))),
                  //Name
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: 8.0),
                      child: Text(
                        StringHelper.upperCaseWords(orderItem.name.value),
                        overflow: TextOverflow.ellipsis,
                        style: FontHelper.bold(Colors.black, 12.0),
                      ),
                    ),
                  )),
                  //Price
                  Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Text(
                          'Max: ${formatCurrency.format(orderItem.price.value)}',
                          style: FontHelper.regular(Colors.black, 12.0),
                        ),
                      )),
                  Align(
                      alignment: Alignment.centerRight,
                      child: ScaleGestureDetector(
                        minScale: 0.8,
                        child: Container(
                            margin: EdgeInsets.only(right: 4.0),
                            height: 20.0,
                            width: 20.0,
                            child: Image.asset(
                                'assets/icons/add_icon_orange.png')),
                        onTap: () {
                          onAddTapped(orderItem);
                        },
                      ))
                ],
              ),
            ),
          ),
          Line(),
        ],
      ),
    );
  }
}
