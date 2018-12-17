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
  final bool showAddItem;
  final double minHeight;
  final bool showSummaryPrice;

  const OrderItemSummary({
    Key key,
    @required this.holders,
    this.showAddItem = true,
    this.showSummaryPrice = false,
    this.minHeight = 200.0,
  }) : super(key: key);

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
          constraints: BoxConstraints(minHeight: widget.minHeight),
          child: Column(
            children: <Widget>[
              buildHeader(),
              Line(
                color: ColorHelper.dabaoOffGreyD3,
              ),
              Container(
                margin: EdgeInsets.only(left: 8.0, bottom: 0.0, right: 8.0),
                child: ColumnBuilder(
                  persistantItemBuilder: widget.showSummaryPrice ? 
                          (context) => Container(
                              padding: EdgeInsets.only(left: 5.0, right: 8.0),
                              height: 40.0,
                              color: Colors.transparent,
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "Est. Subtotal",
                                    style: FontHelper.bold(Colors.black, 12.0),
                                  ),
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Max: " +
                                          StringHelper.doubleToPriceString(items
                                              .map((order) => order.price.value * order.quantity.value)
                                              .toList()
                                              .reduce((price1, price2) =>
                                                  price1 + price2)),style: FontHelper.regular(Colors.black, 14.0),
                                    ),
                                  ))
                                ],
                              )) : null,
                  placeHolderBuilder: (context) {
                    return Container(
                      padding: EdgeInsets.only(top: 25.0,bottom: 25.0),
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
            child: widget.showAddItem
                ? FlatButton(
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
                  )
                : null,
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

        return GestureDetector(
          onTap: () {
            _showSelectionSheet(holder);
          },
          child: Container(
            color: Colors.transparent,
            child: Column(
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
                        padding:
                            EdgeInsets.only(top: 6.0, bottom: 6.0, right: 15.0),
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
                                (holder.description.value == null ||
                                        holder.description.value.isEmpty)
                                    ? "No special instructions"
                                    : holder.description.value,
                                style: FontHelper.bold(
                                    ColorHelper.dabaoOffGrey70, 12.0),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          "Max: " +
                              StringHelper.doubleToPriceString(
                                  holder.price.value),
                          style: FontHelper.regular(Colors.black, 12.0),
                        ),
                      ),
                    )
                  ],
                ),
                Line(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSelectionSheet(OrderItemHolder orderItemHolder) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  onTap: () {
                    Navigator.of(context).pop();

                    showOrderItemEditor(
                      context: context,
                      foodTagTitle: widget.holders.foodTag.value,
                      onCompleteCallback: (OrderItemHolder order) {
                        widget.holders.orderItems.onAdd();
                      },
                      toEdit: orderItemHolder,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap: () {
                    widget.holders.orderItems.value.remove(orderItemHolder);
                    widget.holders.orderItems.onAdd();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                    leading: Icon(Icons.cancel),
                    title: Text('Cancel'),
                    onTap: () {
                      Navigator.of(context).pop();
                    }),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        });
  }
}
