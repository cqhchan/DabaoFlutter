import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/CustomizedMap.dart';
import 'package:flutterdabao/CreateOrder/LocationCard.dart';
import 'package:flutterdabao/CreateOrder/OrderCheckoutCard.dart';
import 'package:flutterdabao/CreateOrder/OrderOverlay.dart';
import 'package:flutterdabao/CustomWidget/Buttons/CustomizedBackButton.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Model/Voucher.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderNow extends StatefulWidget {
  final Voucher voucher;

  OrderNow({Key key, this.voucher}) : super(key: key);

  _OrderNowState createState() =>
      _OrderNowState(holder: OrderHolder(voucher: voucher));
}

class _OrderNowState extends State<OrderNow>
    with HavingSubscriptionMixin {
  // String _address = '20 Heng Mui Keng xTerrace';

  // handle the progress through the application
  MutableProperty<int> progress;

  MutableProperty<bool> checkout = MutableProperty<bool>(false);

  final OrderHolder holder;

  _OrderNowState({this.holder}) {
    
    if (holder.foodTag.value != null)
      progress = MutableProperty<int>(1);
    else
      progress = MutableProperty<int>(0);

  }

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
          CustomizedMap(
            selectedlocation: holder.deliveryLocation,
            selectedlocationDescription: holder.deliveryLocationDescription,
          ),
          CustomizedBackButton(),
          StreamBuilder<bool>(
            stream: checkout.producer,
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
            page: progress,
            checkout: checkout,
          );
        });
  }
}
