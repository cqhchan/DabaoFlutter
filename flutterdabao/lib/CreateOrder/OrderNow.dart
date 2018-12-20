import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/LocationCard.dart';
import 'package:flutterdabao/CreateOrder/OrderCheckoutCard.dart';
import 'package:flutterdabao/CreateOrder/OrderOverlay.dart';
import 'package:flutterdabao/CustomWidget/Buttons/CustomizedBackButton.dart';
import 'package:flutterdabao/CustomWidget/CustomizedMap.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';

import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderNow extends StatefulWidget {

  _OrderNowState createState() => _OrderNowState();
}

class _OrderNowState extends State<OrderNow>
    with HavingSubscriptionMixin, SingleTickerProviderStateMixin {
  // String _address = '20 Heng Mui Keng xTerrace';


  // handle the progress through the application
  MutableProperty<int> progress = MutableProperty<int>(0);

  MutableProperty<bool> checkout = MutableProperty<bool>(false);

  final OrderHolder holder = OrderHolder();

  double newLatitude;
  double newLongitude;

  void initState() {

    super.initState();


    subscription.add(holder.deliveryLocationDescription.producer.listen((location){
      print(location);

    }));
        subscription.add(holder.deliveryLocation.producer.listen((location){
      print(location);

    }));
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
            mode: 0,
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
                  showOverlayCallback: showOverlay, holder: holder,
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
          print(holder.deliveryLocationDescription.value);
          return OrderOverlay(
            holder: holder,
            page: progress,
            checkout: checkout,
          );
        });
  }
}
