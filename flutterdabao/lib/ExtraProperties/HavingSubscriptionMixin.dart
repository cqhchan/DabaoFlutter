import 'package:flutterdabao/HelperClasses/compisite_subscription.dart';
import 'package:rxdart/rxdart.dart';

abstract class HavingSubscriptionMixin {

  CompositeSubscription subscription = new CompositeSubscription();



  //Dispose current subscriptions and resets the subscription;
  disposeAndReset(){

    subscription.dispose();
    subscription = new CompositeSubscription();

  }



}