import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/ColumBuilder.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/OrderItems/OrderItemEditor.dart';

class OrderItemSummary extends StatefulWidget {
  final OrderHolder holders;

  const OrderItemSummary({Key key, @required this.holders}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OrderItemSummaryState();
  }
}

class _OrderItemSummaryState extends State<OrderItemSummary>
    with HavingSubscriptionMixin {
  List<OrderItemHolder> items = List();

  @override
  void initState() {
    super.initState();

    subscription.add(widget.holders.orderItems.producer.listen((holder) {
      setState(() {
        items = holder;
      });
    }));
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(0.0),
        elevation: 0.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 200),
          child: Column(
            children: <Widget>[
              buildHeader(),
              Line(
                color: ColorHelper.dabaoOffGrey70,
              ),
              Container(
                margin: EdgeInsets.only(left: 8.0 , bottom: 8.0, right: 8.0),
                child: ColumnBuilder(
                  placeHolderBuilder: (context) {
                    return Container(
                      padding: EdgeInsets.only(top: 25.0),
                      child: Text(
                        "Your cart seems to be empty! :O\nTap on 'add' to begin ordering!",
                        style: FontHelper.regular(
                            ColorHelper.dabaoOffBlack4A, 14.0),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    return buildCellForOrderItemHolder(items[index]);
                  },
                  itemCount: items.length,
                ),
              )
            ],
          ),
        ));
  }

  Container buildHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 6.0, 6.0, 6.0),
      child: Row(
        children: <Widget>[
          Text("Your Orders",
              style: FontHelper.medium(ColorHelper.dabaoOffBlack4A, 14.0)),
          Icon(Icons.shopping_cart),
          Expanded(
            child: Container(),
          ),
          Container(
            height: 26.0,
            width: 96.0,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.0)),
              color: ColorHelper.dabaoOrange,
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Add item",
                            style: FontHelper.regular(Colors.black, 12.0),
                          ))),
                  Image.asset("assets/icons/plus_icon.png")
                ],
              ),
              onPressed: () {
                showOrderItemCreator(
                    context: context,
                    foodTagTitle: widget.holders.foodTag.value,
                    onCompleteCallback: (OrderItemHolder orderItem) {
                      widget.holders.orderItems.value.add(orderItem);
                      widget.holders.orderItems.onAdd();
                    });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildCellForOrderItemHolder(OrderItemHolder holder) {
    return StreamBuilder<String>(
      stream: holder.title.producer,
      builder: (context, snap) {
        if (!snap.hasData) return Container();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 5.0, right: 15.0),
                    child: Text(
                      holder.quantity.value.toString() + " x",
                      style: FontHelper.bold(Colors.black, 14.0),
                    )),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 6.0, bottom: 6.0, right:15.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            holder.title.value,
                            style: FontHelper.bold(Colors.black, 14.0),
                          ),
                          Text(
                            holder.description.value == null? "" : holder.description.value, 
                            style: FontHelper.bold(Colors.black, 10.0),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text("Max: " + StringHelper.doubleToPriceString(holder.price.value),style: FontHelper.regular(Colors.black, 12.0),),
                )
              ],
            ),
            Line()
          ],
        );
      },
    );
  }
}
