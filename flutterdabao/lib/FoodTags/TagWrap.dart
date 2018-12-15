import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/FoodTag.dart';

typedef SelectedCallBack = void Function(Selectable);

class TagWrap extends StatefulWidget {
  final MutableProperty<List<FoodTag>> taggables;
  final SelectedCallBack selectedCallBack;
  final int limit;

  TagWrap({
    @required this.taggables,
    @required this.selectedCallBack, this.limit = 10,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TagWrapState();
  }
}

class _TagWrapState extends State<TagWrap> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<List<FoodTag>>(
      stream: widget.taggables.producer,
      builder: (context, snap) {
        if (!snap.hasData) {
          return CircularProgressIndicator();
        }

        snap.data.sort((tag1, tag2) {

          if (tag1.reccomended.value && tag2.reccomended.value)
          return 0;

          if (tag1.reccomended.value) return -1;

          if (tag2.reccomended.value) return 1;

          int ttemp = tag2.quantity.value.compareTo(tag1.quantity.value);

          return ttemp;
        });

        List<Widget> listOfWidget = snap.data.take(widget.limit).map((foodTag) {
          return StreamBuilder<String>(
              stream: foodTag.title,
              builder: (context, snap) {
                return _Tag(
                  selectable: foodTag,
                  title: snap.data == null
                      ? ""
                      : StringHelper.upperCaseWords(snap.data),
                  selectedCallBack: widget.selectedCallBack,
                );
              });
        }).toList();

        return Wrap(
          spacing: 15.0,
          children: listOfWidget,
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final Selectable selectable;
  final String title;
  final SelectedCallBack selectedCallBack;

  const _Tag({
    Key key,
    @required this.selectable,
    @required this.title,
    @required this.selectedCallBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(
      pressElevation: 0.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
              color: ColorHelper.dabaoOrange, style: BorderStyle.solid)),
      backgroundColor: ColorHelper.dabaoOffWhiteF5,
      label: Text(
        title,
        style: FontHelper.chipTextStyle,
      ),
      onPressed: () {
        selectedCallBack(selectable);
      },
    );
  }
}
