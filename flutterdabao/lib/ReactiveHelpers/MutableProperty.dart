
import 'dart:async';

import 'package:rxdart/rxdart.dart' as RxDart;
import 'package:observable/observable.dart' ;


class MutableProperty<T> {

  
ObservableList  temp = new ObservableList();

  RxDart.BehaviorSubject<T> _producer;
  RxDart.BehaviorSubject<T> get producer => _producer;
  T get value => _producer.value;
    set value(T t) {
            print("testing add Called");
            _producer.add(t);
          
    }

  onAdd(){

    _producer.onAdd(value);

  }

  MutableProperty(T initialValue){

    _producer = new RxDart.BehaviorSubject<T>(seedValue: initialValue);
  }

StreamSubscription<T> bindTo(RxDart.Observable o ){
    
    return o.listen((t) => _producer.onAdd(t), onError: (e) => _producer.addError(e));

  }

}
