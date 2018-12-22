import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NonStopIO',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool longPressFlag = false;
  List<Element> indexList = new List();

  onelementSelected(int index){
    setState((){
      indexList[index].isselected=!indexList[index].isselected;
    });

  }
  void longPress() {
    setState(() {
      if (indexList.isEmpty) {
        longPressFlag = false;
      } else {
        longPressFlag = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    for(var i=0;i<15;i++){
      indexList.add(Element(isselected: false));
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Selected ${indexList.length}  ' + indexList.toString()),
      ),
      body: new ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return new CustomWidget(
            index: index,
            isselected: indexList[index].isselected,
            
            longPressEnabled: longPressFlag,
            callback: () {
             onelementSelected(index);
             if (indexList.contains(index)) {
                indexList.remove(index);
              } else {
                indexList.add(Element());
              }

              longPress();
            },
          );
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CustomWidget extends StatefulWidget {
  final int index;
  final bool longPressEnabled;
  final VoidCallback callback;
  final bool isselected;

  const CustomWidget({Key key, this.index, this.longPressEnabled, this.callback,this.isselected}) : super(key: key);

  @override
  _CustomWidgetState createState() => new _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onLongPress: () {
        widget.callback();
      },
      onTap: () {
        if (widget.longPressEnabled) {
          widget.callback();
        }
      },
      child: new Container(
        margin: new EdgeInsets.all(5.0),
        child: new ListTile(
          title: new Text("Title ${widget.index}"),
          subtitle: new Text("Description ${widget.index}"),
        ),
        decoration: widget.isselected
            ? new BoxDecoration(color: Colors.black38, border: new Border.all(color: Colors.black))
            : new BoxDecoration(),
      ),
    );
  }
}
class Element{
   bool isselected;
  Element({this.isselected});
 }