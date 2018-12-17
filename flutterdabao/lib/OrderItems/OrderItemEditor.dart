import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/CustomWidget/InputFormatter/CurrencyInputFormatter.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/CustomWidget/Route/OverlayRoute.dart';
import 'package:flutterdabao/CustomWidget/ScaleGestureDetector.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

typedef OrderItemHolderCallback = Function(OrderItemHolder);

Future<T> showOrderItemEditor<T>({
  @required BuildContext context,
  bool barrierDismissible = false,
  @required OrderItemHolder toEdit,
  @required String foodTagTitle,
  @required OrderItemHolderCallback onCompleteCallback,
}) {
  assert(toEdit != null);
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: true)
      .push<T>(CustomOverlayRoute<T>(
    builder: (context) {
      return _OrderItemEditor.edit(
        orderItemHolder: toEdit,
        onComepleteCallback: onCompleteCallback,
        foodTagTitle: foodTagTitle,
      );
    },
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}

Future<T> showOrderItemCreator<T>({
  @required BuildContext context,
  bool barrierDismissible = false,
  @required String foodTagTitle,
  @required OrderItemHolderCallback onCompleteCallback,
  OrderItem creationTemplate,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: true)
      .push<T>(CustomOverlayRoute<T>(
    builder: (context) {
      return _OrderItemEditor.create(
        template: creationTemplate,
        onComepleteCallback: onCompleteCallback,
        foodTagTitle: foodTagTitle,
      );
    },
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}

class _OrderItemEditor extends StatefulWidget {
  final OrderItemHolder orderItemHolder;
  final OrderItemHolderCallback onComepleteCallback;
  final String foodTagTitle;
  _OrderItemEditor.edit(
      {@required this.orderItemHolder,
      this.onComepleteCallback,
      @required this.foodTagTitle});

  _OrderItemEditor.create({
    OrderItem template,
    this.onComepleteCallback,
    @required this.foodTagTitle,
  }) : orderItemHolder = template == null
            ? OrderItemHolder()
            : OrderItemHolder(
                title: template.name.value, price: template.price.value);

  @override
  State<StatefulWidget> createState() {
    return _OrderItemEditorState();
  }
}

class _OrderItemEditorState extends State<_OrderItemEditor> {
  var _titleTextController = new TextEditingController();
  var _subTitleTextController = new TextEditingController();
  var _priceController = new TextEditingController();
  String errorMessage = "";
  int qty;
  @override
  void initState() {
    super.initState();

    _titleTextController.text = widget.orderItemHolder.title.value == null
        ? ""
        : StringHelper.upperCaseWords(widget.orderItemHolder.title.value);

    _subTitleTextController.text = (widget.orderItemHolder.description.value ==
                null ||
            widget.orderItemHolder.description.value.isEmpty)
        ? ""
        : StringHelper.upperCaseWords(widget.orderItemHolder.description.value);

    _priceController.text = widget.orderItemHolder.price.value == null
        ? "\$0.00"
        : "\$" + widget.orderItemHolder.price.value.toStringAsFixed(2);

    qty = widget.orderItemHolder.quantity.value == null
        ? 1
        : widget.orderItemHolder.quantity.value;
  }

  @override
  void dispose() {
    super.dispose();
  }

  addQty() {
    if (qty < 9) {
      setState(() {
        qty = qty + 1;
      });
    }
  }

  minusQty() {
    if (qty > 1) {
      setState(() {
        qty = qty - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){FocusScope.of(context).requestFocus(new FocusNode());
},
          child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
            alignment: Alignment(0, 0),
            margin: EdgeInsets.only(left: 45.0,right: 45.0),

            //Card is required for Mateials Design
            child: Card(
              color: Colors.transparent,
              // Set the height and width of the widget
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300, maxHeight: 360),

                // Set the container styling
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white),

                  //Contents
                  child: Column(
                    children: <Widget>[
                      // Close button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      //Rest of content
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 18.0, right: 18.0, bottom: 18.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  "CUSTOMISE YOUR ORDER",
                                  style: FontHelper.bold(
                                      ColorHelper.dabaoOffBlack4A, 12.0),
                                ),
                              ),
                              buildTitleTextField(),
                              Container(
                                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                                child: Text(
                                  "Special Instructions",
                                  style: FontHelper.medium(
                                      ColorHelper.dabaoOffBlack4A, 12.0),
                                ),
                              ),
                              buildDescriptionTextField(),
                              buildPrice(),
                              buildQty(),
                              buildErrorMessage(),
                              buildBottomButton(context)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Align buildBottomButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FlatButton(
        color: ColorHelper.dabaoOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Add To Basket",
                      style: FontHelper.semiBold(Colors.black, 14.0),
                    ))),
            Image.asset("assets/icons/arrow_right_white_circle.png")
          ],
        ),
        onPressed: () {
          if (_priceController.text != null &&
              _priceController.text.isNotEmpty &&
              _titleTextController.text != null &&
              _titleTextController.text.isNotEmpty &&
              qty != 0) {
            widget.orderItemHolder.title.value = _titleTextController.text;
            widget.orderItemHolder.description.value =
                _subTitleTextController.text;
            widget.orderItemHolder.price.value =
                StringHelper.stringPriceToDouble(_priceController.text);
            widget.orderItemHolder.quantity.value = qty;
            widget.onComepleteCallback(widget.orderItemHolder);
            Navigator.of(context).pop();
          } else {
            setState(() {
              errorMessage = "Please Fill in all blanks";
            });
          }
        },
      ),
    );
  }

  Expanded buildErrorMessage() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          child: Text(
            errorMessage,
            style: FontHelper.semiBold(Colors.red, 12.0),
          ),
        ),
      ),
    );
  }

  Row buildQty() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Quantity:",
              style: FontHelper.medium(Colors.black, 12.0),
            ),
          ),
        ),
        ScaleGestureDetector(
          onTap: minusQty,
          child: Image.asset('assets/icons/minus_filled_icon.png'),
        ),
        Container(
            width: 30.0,
            padding: EdgeInsets.only(right: 10.0, left: 10.0),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  qty.toString(),
                  style: FontHelper.bold(Colors.black, 14.0),
                ))),
        ScaleGestureDetector(
          onTap: addQty,
          child: Image.asset('assets/icons/add_filled_icon.png'),
        ),
      ],
    );
  }

  Container buildPrice() {
    return Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Text(
            "Max Price:",
            style: FontHelper.medium(Colors.black, 12.0),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(left: 10.0),
                width: 60,
                child: CupertinoTextField(
                  controller: _priceController,
                  textAlign: TextAlign.center,
                  style: FontHelper.medium(Colors.black, 14.0),
                  keyboardType: TextInputType.numberWithOptions(),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    CurrencyInputFormatter(),
                    LengthLimitingTextInputFormatter(6),
                  ],
                  placeholder: "\$0.00",
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField buildDescriptionTextField() {
    return TextFormField(
      controller: _subTitleTextController,
      inputFormatters: [
        new LengthLimitingTextInputFormatter(40),
      ],
      maxLines: 3,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      style: FontHelper.medium(Colors.black, 12.0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10.0),
          border: OutlineInputBorder(gapPadding: 0.0),
          hintText: 'e.g. Add Egg, Add Mashed Potato'),
    );
  }

  Widget buildTitleTextField() {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        autofocus: false,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [
          new LengthLimitingTextInputFormatter(20),
        ],
        controller: _titleTextController,
        autocorrect: false,
        style: FontHelper.medium(Colors.black, 14.0),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10.0),
            border: OutlineInputBorder(gapPadding: 0.0),
            hintText: 'e.g. Grilled Fish Pasta'),
      ),
      noItemsFoundBuilder: (context) {
        return Text("No Suggestions");
      },
      suggestionsCallback: (pattern) async {
        return await FirebaseCollectionReactiveOnce<OrderItem>(Firestore
                .instance
                .collection("foodTags")
                .document(widget.foodTagTitle.toLowerCase())
                .collection("orderItems")
                .where(OrderItem.titleKey,
                    isGreaterThanOrEqualTo: pattern.toLowerCase())
                .where(OrderItem.titleKey,
                    isLessThanOrEqualTo: pattern.toLowerCase() + "z")
                .orderBy(OrderItem.titleKey)
                .limit(5))
            .future;
      },
      itemBuilder: (context, dynamic suggestion) {
        OrderItem orderItem = suggestion;
        return Container(
          height: 40.0,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          margin: EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Text(
                            StringHelper.upperCaseWords(orderItem.name.value),
                            overflow: TextOverflow.ellipsis,
                          )))),
              Align(alignment: Alignment.bottomCenter, child: Line())
            ],
          ),
        );
      },
      onSuggestionSelected: (suggestion) {
        OrderItem orderItem = suggestion;

        _titleTextController.text =
            StringHelper.upperCaseWords(orderItem.name.value);

        _priceController.text =
            StringHelper.doubleToPriceString(orderItem.price.value);
      },
    );
  }
}
