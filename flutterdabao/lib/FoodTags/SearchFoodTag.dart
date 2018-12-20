import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/FoodTag.dart';
import 'package:material_search/material_search.dart';

typedef StringSelectedCallback = void Function(String);

class FoodTypeSearch extends StatefulWidget {
  final StringSelectedCallback selectedCallback;

  const FoodTypeSearch({Key key, @required this.selectedCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FoodTypeSearchState();
  }
}

class _FoodTypeSearchState extends State<FoodTypeSearch> {
  static const _list = const [
    'Igor Minar',
    'Brad Green',
    'Dave Geddes',
    'Naomi Black',
    'Greg Weber',
    'Dean Sofer',
    'Wes Alvaro',
    'John Scott',
    'Daniel Nadasi',
  ];

  @override
  Widget build(BuildContext context) {
          return new MaterialSearch(
        placeholder: 'Search e.g. Gongcha, Macdonalds', //placeholder of the search bar text input

        getResults: (String criteria) async {
          List<FoodTag> list = await FirebaseCollectionReactiveOnce<FoodTag>(
                  Firestore.instance
                      .collection('foodTags')
                      .orderBy(FoodTag.titleKey)
                      .where(FoodTag.titleKey,
                          isGreaterThanOrEqualTo: criteria.toLowerCase().trim())
                      .where(FoodTag.titleKey,
                          isLessThanOrEqualTo: criteria.toLowerCase().trim() + "z")
                      .limit(10))
              .future;
          List resultList = list
              .map((tag) => new MaterialSearchResult<dynamic>(
                    value: tag, //The value must be of type <String>
                    text: StringHelper.upperCaseWords(
                        tag.title.value), //String that will be show in the list
                  ))
              .toList();

          if (criteria.isNotEmpty) {
            resultList.add(MaterialSearchResult(
                text: "Select \"" + criteria + "\"",
                value: criteria,
                icon: IconData(0xe3ba, fontFamily: 'MaterialIcons')));
          }

          return resultList;
        },

        //callback when some value is selected, optional.
        onSelect: (dynamic selected) {
          String title;

          if (selected is FoodTag) {
            FoodTag selectedTag = selected;

            title = selectedTag.title.value;
          } else {
            title = selected.toLowerCase();
          }
          widget.selectedCallback(title.trim());
          Navigator.of(context).pop();
        },
        //callback when the value is submitted, optional.
        onSubmit: (String value) {
          print(value);
        },
      );
  }
}
