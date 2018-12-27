import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MutableProperty<T> {
  BehaviorSubject<T> _producer;
  BehaviorSubject<T> get producer => _producer;
  T get value => _producer.value;
  set value(T t) {
    _producer.add(t);
  }

  onAdd() {
    _producer.add(value);
  }

  MutableProperty(T initialValue) {
    _producer = new BehaviorSubject<T>(seedValue: initialValue);
  }

  StreamSubscription<T> bindTo(Stream<T> o) {
    return o.listen((t) => _producer.add(t),
        onError: (e) => _producer.addError(e));
  }
}

Stream<List<T>> combineAndMerge<T>(
    List<Stream<List<T>>> listToCombineAndMerge) {

  Stream<List<T>> observable = listToCombineAndMerge.removeLast();

  while (listToCombineAndMerge.length > 0) {
    switch (listToCombineAndMerge.length) {
      case 1:
        observable = Observable.combineLatest2<List<T>, List<T>, List<T>>(
            observable, listToCombineAndMerge.removeLast(), (first, second) {
          List<T> temp = List();
          temp.addAll(first);
          temp.addAll(second);
          return temp;
        });
        break;
      case 2:
        observable =
            Observable.combineLatest3<List<T>, List<T>, List<T>, List<T>>(
                observable,
                listToCombineAndMerge.removeLast(),
                listToCombineAndMerge.removeLast(), (first, second, third) {
          List<T> temp = List();
          temp.addAll(first);
          temp.addAll(second);
          temp.addAll(third);
          return temp;
        });
        break;

      case 3:
        observable = Observable.combineLatest4<List<T>, List<T>, List<T>,
                List<T>, List<T>>(
            observable,
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(), (first, second, third, forth) {
          List<T> temp = List();
          temp.addAll(first);
          temp.addAll(second);
          temp.addAll(third);
          temp.addAll(forth);
          return temp;
        });
        break;

      case 4:
        observable = Observable.combineLatest5<List<T>, List<T>, List<T>,
                List<T>, List<T>, List<T>>(
            observable,
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            (first, second, third, forth, fifth) {
          List<T> temp = List();
          temp.addAll(first);
          temp.addAll(second);
          temp.addAll(third);
          temp.addAll(forth);
          temp.addAll(fifth);
          return temp;
        });
        break;

      case 5:
        observable = Observable.combineLatest6<List<T>, List<T>, List<T>,
                List<T>, List<T>, List<T>, List<T>>(
            observable,
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            (first, second, third, forth, fifth, sixth) {
          List<T> temp = List();

          temp.addAll(first);
          temp.addAll(second);
          temp.addAll(third);
          temp.addAll(forth);
          temp.addAll(fifth);
          temp.addAll(sixth);
          return temp;
        });
        break;

      case 6:
        observable = Observable.combineLatest7<List<T>, List<T>, List<T>,
                List<T>, List<T>, List<T>, List<T>, List<T>>(
            observable,
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            (first, second, third, forth, fifth, sixth, seventh) {
          List<T> temp = List();
          temp.addAll(first);
          temp.addAll(second);
          temp.addAll(third);
          temp.addAll(forth);
          temp.addAll(fifth);
          temp.addAll(sixth);
          temp.addAll(seventh);

          return temp;
        });
        break;

      case 7:
        observable = Observable.combineLatest8<List<T>, List<T>, List<T>,
                List<T>, List<T>, List<T>, List<T>, List<T>, List<T>>(
            observable,
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            (first, second, third, forth, fifth, sixth, seventh, eigth) {
          List<T> temp = List();
          temp.addAll(first);
          temp.addAll(second);
          temp.addAll(third);
          temp.addAll(forth);
          temp.addAll(fifth);
          temp.addAll(sixth);
          temp.addAll(seventh);
          temp.addAll(eigth);

          return temp;
        });
        break;

      default:
        observable = Observable.combineLatest9<List<T>, List<T>, List<T>,
                List<T>, List<T>, List<T>, List<T>, List<T>, List<T>, List<T>>(
            observable,
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            listToCombineAndMerge.removeLast(),
            (first, second, third, forth, fifth, sixth, seventh, eigth, ninth) {
          List<T> temp = List();

          temp.addAll(first);
          temp.addAll(second);
          temp.addAll(third);
          temp.addAll(forth);
          temp.addAll(fifth);
          temp.addAll(sixth);
          temp.addAll(seventh);
          temp.addAll(eigth);
          temp.addAll(ninth);

          return temp;
        });
        break;
    }
  }

  return observable;
}
