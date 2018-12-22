import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class RouteHolder {
  //Complusory
  MutableProperty<LatLng> startDeliveryLocation = MutableProperty(null);
  MutableProperty<String> startDeliveryLocationDescription =
      MutableProperty(null);
  MutableProperty<LatLng> endDeliveryLocation = MutableProperty(null);
  MutableProperty<String> endDeliveryLocationDescription =
      MutableProperty(null);

  MutableProperty<List<String>> foodTags = MutableProperty(List());

  MutableProperty<DateTime> deliveryTime = MutableProperty(null);

}
