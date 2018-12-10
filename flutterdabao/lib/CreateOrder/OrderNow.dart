import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/LocationCard.dart';

import 'package:flutterdabao/CustomWidget/CustomizedBackButton.dart';
import 'package:flutterdabao/CustomWidget/CustomizedMap.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';

import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';



class OrderNow extends StatefulWidget {
  final OrderHolder holder = OrderHolder();

  _OrderNowState createState() => _OrderNowState();
}

class _OrderNowState extends State<OrderNow>
    with HavingSubscriptionMixin, SingleTickerProviderStateMixin {
  // String _address = '20 Heng Mui Keng xTerrace';
  MutableProperty<LatLng> deliveryLocation;
  MutableProperty<String> deliveryLocationDescription;


  // handle the progress through the application
  MutableProperty<int> progress = MutableProperty<int>(0);

  double newLatitude;
  double newLongitude;

  void initState() {
    deliveryLocation = widget.holder.deliveryLocation;
    deliveryLocationDescription = widget.holder.deliveryLocationDescription;
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
            mode: 0,
            selectedlocation: deliveryLocation,
          ),
          CustomizedBackButton(),
          LocationCard(selectedLocationDescription: deliveryLocationDescription, selectedLocation: deliveryLocation,),
        ],
      ),
    );
  }
}


