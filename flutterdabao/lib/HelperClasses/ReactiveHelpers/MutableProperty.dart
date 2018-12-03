
import 'dart:async';

import 'package:rxdart/rxdart.dart' as RxDart;


class MutableProperty<T> {

  

  RxDart.BehaviorSubject<T> _producer;
  RxDart.BehaviorSubject<T> get producer => _producer;
  T get value => _producer.value;
    set value(T t) {
            _producer.add(t);
          
    }

  onAdd(){

    _producer.add(value);

  }

  MutableProperty(T initialValue){

    _producer = new RxDart.BehaviorSubject<T>(seedValue: initialValue);
  }

StreamSubscription<T> bindTo(RxDart.Observable<T> o ){
    
    print("New Test " +T.runtimeType.toString());

    return o.listen((t) => _producer.onAdd(t), onError: (e) => _producer.addError(e));

  }

}
