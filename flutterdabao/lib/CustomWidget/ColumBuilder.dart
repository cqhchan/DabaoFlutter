import 'package:flutter/cupertino.dart';

class ColumnBuilder extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final WidgetBuilder placeHolderBuilder;
  final WidgetBuilder persistantItemBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection textDirection;
  final VerticalDirection verticalDirection;
  final int itemCount;

  const ColumnBuilder({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    this.mainAxisAlignment: MainAxisAlignment.start,
    this.mainAxisSize: MainAxisSize.max,
    this.crossAxisAlignment: CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection: VerticalDirection.down,
    this.placeHolderBuilder,
    this.persistantItemBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {

    return _ColumnBuilderState();
  }
}

class _ColumnBuilderState extends State<ColumnBuilder> {
  @override
  Widget build(BuildContext context) {

    List<Widget> listOfWidget;

    listOfWidget = widget.itemCount == 0 && widget.placeHolderBuilder != null
          ? [widget.placeHolderBuilder(context)]
          : new List.generate(widget.itemCount,
              (index) => widget.itemBuilder(context, index)).toList();

    if (widget.itemCount != 0 && widget.persistantItemBuilder != null){
      listOfWidget.add(widget.persistantItemBuilder(context));
    }

    return new Column(
      children: listOfWidget,
    );
  }
}
