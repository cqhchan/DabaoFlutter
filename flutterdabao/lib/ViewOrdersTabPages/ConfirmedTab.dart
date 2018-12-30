import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/ViewOrdersTabPages/AcceptedList.dart';
import 'package:rxdart/rxdart.dart';

class ConfirmedTabView extends StatefulWidget {

    const ConfirmedTabView({Key key}): super(key: key);

  _ConfirmedTabViewState createState() => _ConfirmedTabViewState();
}

class _ConfirmedTabViewState extends State<ConfirmedTabView>   with AutomaticKeepAliveClientMixin<ConfirmedTabView>{
  final MutableProperty<List<Order>> userAcceptedOrders =
      ConfigHelper.instance.currentUserDeliveringOrdersProperty;

  final MutableProperty<List<Order>> userCompletedOrders =
      ConfigHelper.instance.currentUserDeliveredCompletedOrdersProperty;

  @override
  void dispose() {
    // TODO: implement dispose
    Selectable.deselectAll(userAcceptedOrders.value);
    Selectable.deselectAll(userCompletedOrders.value);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    
    return Scaffold(
      body: AcceptedList(
        context: context,
        input:
            Observable.combineLatest2<List<Order>, List<Order>, List<Order>>(
                userAcceptedOrders.producer, userCompletedOrders.producer,
                (x, y) {
          List<Order> temp = List();
          if (x != null && x.length != 0) temp.addAll(x);
          if (y != null && y.length != 0) temp.addAll(y);
          return temp;
        }),
        location: ConfigHelper.instance.currentLocationProperty.value,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
