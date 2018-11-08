
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Model/Location.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/ReactiveHelpers/MutableProperty.dart';
import 'package:rxdart/rxdart.dart';
class ConfigHelper with HavingSubscriptionMixin{

  MutableProperty<User> currentUserProperty = MutableProperty<User>(null); 
  MutableProperty<List<Location>> allLocationsProperty = MutableProperty<List<Location>>(List<Location>()); 


  static ConfigHelper get instance => _internal != null ? _internal: ConfigHelper._create() ;
  static ConfigHelper _internal;
  
  ConfigHelper._create(){
      _internal = this;
  }



  // Called once when app loads.
  appDidLoad(){
    disposeAndReset();

    subscription.add(allLocationsProperty.bindTo(allLocationProducer()));


  }

  Observable<List<Location>> allLocationProducer(){


  return currentUserProperty.producer.switchMap((user) => user == null? Observable.just(List<Location>()):FirebaseCollectionReactive<Location>(Firestore.instance.collection("locations")).observable);

  }
}