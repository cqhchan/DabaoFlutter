import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';


abstract class PageHandler {

  BehaviorSubject<int> get pageNumberSubject;

  nextPage(){ 
    pageNumberSubject.add(pageNumberSubject.value + 1 );}

  previousPage(){ pageNumberSubject.add(pageNumberSubject.value - 1 );}

  Widget pageForNumber(int pageNumber);
}

class PageTurner extends StatefulWidget {
  final PageHandler _handler;

  PageTurner(this._handler);

  @override
  _PageTurnerState createState() {
    return _PageTurnerState();
  }
}

class _PageTurnerState extends State<PageTurner> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: widget._handler.pageNumberSubject,
      builder: (context, snap) => widget._handler.pageForNumber(snap.data),
    );
  }
}
