import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

// class FAQ extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       title: 'Streams Demo',
//       theme: dabaoColourScheme,
//       home: BlocProvider<IncrementBloc>(
//         bloc: IncrementBloc(),
//         child: CounterPage(),
//       ),
//     );
//   }
// }

// class CounterPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final IncrementBloc bloc = BlocProvider.of<IncrementBloc>(context);

//     return Scaffold(
//       appBar: AppBar(title: Text('Stream version of the Counter App')),
//       body: Center(
//         child: StreamBuilder<int>(
//             stream: bloc.outCounter,
//             initialData: 0,
//             builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
//               return Text('You hit me: ${snapshot.data} times');
//             }),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () {
//           bloc.incrementCounter.add(null);
//         },
//       ),
//     );
//   }
// }

// class IncrementBloc implements BlocBase {
//   int _counter;

//   //
//   // Stream to handle the counter
//   //
//   StreamController<int> _counterController = StreamController<int>();
//   StreamSink<int> get _inAdd => _counterController.sink;
//   Stream<int> get outCounter => _counterController.stream;

//   //
//   // Stream to handle the action on the counter
//   //
//   StreamController _actionController = StreamController();
//   StreamSink get incrementCounter => _actionController.sink;

//   //
//   // Constructor
//   //
//   IncrementBloc() {
//     _counter = 0;
//     _actionController.stream.listen(_handleLogic);
//   }

//   void dispose() {
//     _actionController.close();
//     _counterController.close();
//   }

//   void _handleLogic(data) {
//     _counter = _counter + 1;
//     _inAdd.add(_counter);
//   }
// }

// // Generic Interface for all BLoCs
// abstract class BlocBase {
//   void dispose();
// }

// // Generic BLoC provider
// class BlocProvider<T extends BlocBase> extends StatefulWidget {
//   BlocProvider({
//     Key key,
//     @required this.child,
//     @required this.bloc,
//   }) : super(key: key);

//   final T bloc;
//   final Widget child;

//   @override
//   _BlocProviderState<T> createState() => _BlocProviderState<T>();

//   static T of<T extends BlocBase>(BuildContext context) {
//     final type = _typeOf<BlocProvider<T>>();
//     BlocProvider<T> provider = context.ancestorWidgetOfExactType(type);
//     return provider.bloc;
//   }

//   static Type _typeOf<T>() => T;
// }

// class _BlocProviderState<T> extends State<BlocProvider<BlocBase>> {
//   @override
//   void dispose() {
//     widget.bloc.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }

class FAQ extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text("check"),
          ),
          drawer: XmobeMenu(5),
        ),

      );
    }
  }

  final List<MenuItem> menuItems = <MenuItem>[
    MenuItem(0,'Home',Icons.home,Icons.chevron_right),
    MenuItem(0,'Home',Icons.home,Icons.chevron_right),
    MenuItem(0,'Home',Icons.home,Icons.chevron_right),
    MenuItem(0,'Home',Icons.home,Icons.chevron_right),
    MenuItem(0,'Home',Icons.home,Icons.chevron_right),
    MenuItem(0,'Home',Icons.home,Icons.chevron_right),
    MenuItem(0,'Home',Icons.home,Icons.chevron_right),
  ];

  class XmobeMenu extends StatelessWidget {
    int indexNumber;
    XmobeMenu(int menuIndex)
    {
      indexNumber =menuIndex;
    }
    @override
    Widget build(BuildContext context) {
      return Drawer(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return MenuItemWidget(menuItems[index],indexNumber);
          },
          itemCount: menuItems.length,
        ),
      );
    }
  }

  class MenuItem {
    MenuItem(this.itemNumber,this.title, this.leadIcon, this.trailIcon,);
    final int itemNumber;
    final IconData leadIcon;
    final IconData trailIcon;
    final String title;
  }

  class MenuItemWidget extends StatelessWidget {
    final MenuItem item;
    final int indexNumber;
    const MenuItemWidget(this.item, this.indexNumber);

    Widget _buildMenu(MenuItem menuItem, context) {
      return InkWell(
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (BuildContext context) => FAQ(),
              ),
            );
          },
          child: new Container(
            color: const Color.fromARGB(0, 245,245,245),
            child: new Column(
              children: <Widget>[
                new Column( children: <Widget>[
                  Container(
                    padding: new EdgeInsets.all(8.0), // what ever padding you want add here
                    child: Row(
                      children: <Widget>[
                        new Icon(menuItem.leadIcon),
                        new Expanded (
                          child: new Text(menuItem.title),
                        ),
                        new Icon(menuItem.trailIcon),
                      ],
                    )
                  ),
                  Divider(height: 1.0,color: Colors.grey,),
                ],)
              ],
            ),

          ),
        );
    }
    bool _checkEnabled(int itemNumber, int index)
    {
      if(itemNumber==index) {
        return true;
      }
      else
      {
        return false;
      }
    }
    @override
    Widget build(BuildContext context) {
      return _buildMenu(this.item, context);
    }


  }