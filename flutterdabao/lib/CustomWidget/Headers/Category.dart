import 'package:flutter/cupertino.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/Firebase/FirebaseType.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:rxdart/rxdart.dart';

class Category extends FirebaseType
    with HeaderTitle, Selectable, HavingSubscriptionMixin {
  BehaviorSubject<String> titleProducer;
  List<String> _subcategory;
  String _subname;
  int _index;

  Category.fromDocument(DocumentSnapshot doc) : super.fromDocument(doc);

  String get subname => _subname;

  set subname(String value) {
    _subcategory[_index] = value;
  }

  int get index => _index;

  set index(int value) {
    _index = value;
  }

  @override
  void map(Map<String, dynamic> data) {
    if (data.containsKey("title")) {
      this.title = data["title"];
    }
    // if (data.containsKey("subname")) {
    //   this.subname = data["subname"];
    // }
  }

  @override
  void setUpVariables() {
    titleProducer = BehaviorSubject();

    //  subscription.add(titleProducer.listen((subname) {
    //   this.subname = subname;
    // }));

    subscription.add(titleProducer.listen((title) {
      this.title = title;
    }));
  }
}

class HeaderTitle {
  String title;
}

class Header extends StatefulWidget {
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  // List<Category> _category = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Header1(),
    );
  }
}

class Header1 extends StatelessWidget {

  Widget _buildChoiceChip(BuildContext context, Category cat) {
    return StreamBuilder(
      stream: cat.titleProducer,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return InputChip(
          pressElevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
                color: ColorHelper.dabaoOrange, style: BorderStyle.solid),
          ),
          backgroundColor: ColorHelper.dabaoOffWhiteF5,
          label: Text(
            snapshot.data,
            style: FontHelper.chipTextStyle,
          ),
          onPressed: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<List<Category>>(
          future: FirebaseCollectionReactiveOnce<Category>(
                  Firestore.instance.collection("category"))
              .future,
          builder: (context, snapshot) {
            // QuerySnapshot temp = snapshot.data;
            // if (!snapshot.hasData) return const Text('Loading...');
            // List<Category> tempUsers =
            //     temp.documents.map((doc) => Category.fromDocument(doc)).toList();

            List<Category> tempUsers = snapshot.data;
            List<Widget> widgets =
                tempUsers.map((cat) => _buildChoiceChip(context, cat)).toList();
            // return Wrap( children: <Widget>[_buildChoiceChip(context, snapshot.data.documents[index])],);
            // ListView.builder(
            //   itemExtent: 45.0,
            //   itemCount: snapshot.data.documents.length,
            //   itemBuilder: (context, index) =>
            //       _buildChoiceChip(context, snapshot.data.documents[index]),
            // );
            return Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: widgets,
            );
          },
        ),
      ),
    );
  }
}
