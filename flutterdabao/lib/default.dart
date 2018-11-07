import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutterdabao/tabs/home.dart' as _firstTab;
import 'package:flutterdabao/tabs/chat.dart' as _secondTab;
import 'package:flutterdabao/tabs/profile.dart' as _thirdTab;
import 'package:flutterdabao/style/home_style.dart';
import 'package:flutterdabao/initial/login.dart';

class Default extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new MaterialApp(
        title: 'DABAO',
        theme: dabaoColourScheme,
        home: new Tabs(),
        routes: <String, WidgetBuilder>{
          '/loginpage': (BuildContext context) => LoginPage(),
          '/defaultpage': (BuildContext context) => Default(),
        },
      );
}

class Tabs extends StatefulWidget {
  @override
  TabsState createState() => new TabsState();
}

class TabsState extends State<Tabs> {
  PageController _tabController;

  var _title_app = null;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = new PageController();
    this._title_app = TabItems[0].title;
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        //App Bar
        appBar: new AppBar(
          title: new Text(
            _title_app,
            style: new TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),

        //Content of tabs
        body: new PageView(
          controller: _tabController,
          onPageChanged: onTabChanged,
          children: <Widget>[
            new _firstTab.Home(),
            new _secondTab.Chat(),
            new _thirdTab.Profile(),
          ],
        ),

        //Tabs
        bottomNavigationBar: Theme.of(context).platform == TargetPlatform.iOS
            ? new CupertinoTabBar(
                activeColor: Colors.yellow,
                currentIndex: _tab,
                onTap: onTap,
                items: TabItems.map((TabItem) {
                  return new BottomNavigationBarItem(
                    title: new Text(TabItem.title),
                    icon: new Icon(TabItem.icon),
                  );
                }).toList(),
              )
            : new BottomNavigationBar(
                currentIndex: _tab,
                onTap: onTap,
                items: TabItems.map((TabItem) {
                  return new BottomNavigationBarItem(
                    title: new Text(TabItem.title),
                    icon: new Icon(TabItem.icon),
                  );
                }).toList(),
              ),
      );

  void onTap(int tab) {
    _tabController.jumpToPage(tab);
  }

  void onTabChanged(int tab) {
    setState(() {
      this._tab = tab;
    });

    switch (tab) {
      case 0:
        this._title_app = TabItems[0].title;
        break;

      case 1:
        this._title_app = TabItems[1].title;
        break;

      case 2:
        this._title_app = TabItems[2].title;
        break;
    }
  }
}

class TabItem {
  const TabItem({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<TabItem> TabItems = const <TabItem>[
  const TabItem(title: 'Home', icon: Icons.home),
  const TabItem(title: 'Chat', icon: Icons.chat),
  const TabItem(title: 'Profile', icon: Icons.person)
];
