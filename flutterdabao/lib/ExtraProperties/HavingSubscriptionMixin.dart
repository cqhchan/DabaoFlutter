import 'package:rxdart/rxdart.dart';

abstract class HavingSubscriptionMixin {

  CompositeSubscription subscription = new CompositeSubscription();


  disposeAndReset(){

    subscription.dispose();
    subscription = new CompositeSubscription();

  }


}