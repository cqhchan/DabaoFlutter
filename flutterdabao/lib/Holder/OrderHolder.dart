import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum OrderMode { asap, scheduled }

class OrderHolder {
  //Complusory
  MutableProperty<OrderMode> mode = MutableProperty(null);
  MutableProperty<LatLng> deliveryLocation = MutableProperty(null);
  MutableProperty<String> foodTag = MutableProperty(null);
  MutableProperty<List<OrderItem>> orderItems = MutableProperty(null);
  MutableProperty<DateTime> startDeliveryTime = MutableProperty(null);
  //Optional
  MutableProperty<DateTime> endDeliveryTime = MutableProperty(null);
  MutableProperty<String> message = MutableProperty(null);
}
