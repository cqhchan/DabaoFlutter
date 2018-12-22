import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/ExpansionTile.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/User.dart';

class TabBarDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.home,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        title: Text(
          'DABAOER',
          style: FontHelper.header3TextStyle,
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1.5)]),
              constraints: BoxConstraints(maxHeight: 45.0),
              child: Material(
                color: Colors.white,
                child: TabBar(
                  labelStyle: FontHelper.normal2TextStyle,
                  labelColor: ColorHelper.dabaoOrange,
                  unselectedLabelColor: ColorHelper.dabaoOffGrey70,
                  tabs: [
                    Tab(
                      text: 'Browse Orders',
                    ),
                    Tab(
                      text: 'Confirmed',
                    ),
                    Tab(
                      text: 'My Route',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BrowseOrderTabView(),
                  ConfirmedTabView(),
                  MyRouteTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowseOrderTabView extends StatefulWidget {
  _BrowseOrderTabViewState createState() => _BrowseOrderTabViewState();
}

class _BrowseOrderTabViewState extends State<BrowseOrderTabView>
    with Selectable {
  final MutableProperty<List<Order>> userRequestedOrders =
      ConfigHelper.instance.currentUserRequestedOrdersProperty;

  

  bool _pickUpButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: userRequestedOrders.producer,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data);
      },
    );
  }

  Widget _buildList(BuildContext context, List<Order> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
    // return ListView.builder(
    //   itemCount: snapshot.length,
    //   itemBuilder: (context, index){
    //   },
    // );
  }

  Widget _buildListItem(BuildContext context, Order order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(10.0),
      color: Colors.white,
      elevation: 6.0,
      child: Container(
        margin: EdgeInsets.all(10),
        child: Wrap(
          children: <Widget>[
            StreamBuilder(
              stream: order.deliveryLocationDescription,
              builder: (context, snap) {
                return ConfigurableExpansionTile(
                  onExpansionChanged: (value) {
                    setState(() {
                      _pickUpButton = value;
                    });
                  },
                  header: Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      _buildHeader(order),
                      _buildDeliveryPeriod(order),
                      buildHeightBox(),
                      _buildLocationDescription(order),
                    ],
                  ),
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        buildHeightBox(),
                        _buildOrderItems(order),
                      ],
                    )
                  ],
                );
              },
            ),
            buildHeightBox(),
            Divider(),
            buildHeightBox(),
            _buildUser(order),
            buildHeightBox(),
            _buildPickUpButton(),
          ],
        ),
      ),
    );
  }

  Container _buildHeader(Order order) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 50),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            child: StreamBuilder<String>(
              stream: order.foodTag,
              builder: (context, snap) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    snap.hasData
                        ? StringHelper.upperCaseWords(snap.data)
                        : "Error",
                    style: FontHelper.semiBold16Black,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<String>(
              stream: order.foodTag,
              builder: (context, snap) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    snap.hasData ? '5 Items' : "Error",
                    style: FontHelper.medium14TextStyle,
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: StreamBuilder<double>(
              stream: order.deliveryFee,
              builder: (context, snap) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    snap.hasData
                        ? StringHelper.doubleToPriceString(snap.data)
                        : "Error",
                    style: FontHelper.semiBold14Black2,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Row _buildDeliveryPeriod(Order order) {
    return Row(
      children: <Widget>[
        StreamBuilder<DateTime>(
          stream: order.startDeliveryTime,
          builder: (context, snap) {
            return Container(
              child: Text(
                snap.hasData
                    ? DateTimeHelper.convertStartTimeToDisplayString(snap.data)
                    : "Error",
                style: FontHelper.semiBoldgrey12TextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        StreamBuilder<DateTime>(
          stream: order.endDeliveryTime,
          builder: (context, snap) {
            return Material(
              child: Text(
                snap.hasData
                    ? ' - ' +
                        DateTimeHelper.convertEndTimeToDisplayString(snap.data)
                    : '',
                style: FontHelper.semiBoldgrey12TextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],
    );
  }

  StreamBuilder _buildOrderItems(Order order) {
    return StreamBuilder<List<OrderItem>>(
      stream: order.orderItems,
      builder: (context, snap) {
        if (snap.hasError) return Text('Error: ${snap.error}');
        if (!snap.hasData) return LinearProgressIndicator();
        return _buildOrderItemList(context, snap.data);
      },
    );
  }

  Widget _buildOrderItemList(BuildContext context, List<OrderItem> snapshot) {
    return Wrap(
      // shrinkWrap: true,
      // padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildOrderItem(context, data)).toList(),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem orderItem) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxHeight: 40),
        padding: EdgeInsets.all(6),
        color: Colors.grey[200],
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Image.asset('assets/icons/icon_menu_orange.png')),
            Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    StreamBuilder(
                      stream: orderItem.name,
                      builder: (context, item) {
                        return Text(
                          '${item.data}',
                          style: FontHelper.bold12Black,
                        );
                      },
                    ),
                    StreamBuilder(
                      stream: orderItem.description,
                      builder: (context, item) {
                        return Text(
                          '${item.data}',
                          style: FontHelper.medium10TextStyle,
                        );
                      },
                    ),
                  ],
                )),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  StreamBuilder(
                    stream: orderItem.price,
                    builder: (context, item) {
                      return Text(
                        StringHelper.doubleToPriceString(item.data),
                        style: FontHelper.regular10Black,
                      );
                    },
                  ),
                  StreamBuilder(
                    stream: orderItem.quantity,
                    builder: (context, item) {
                      return Text(
                        'X${item.data}',
                        style: FontHelper.bold12Black,
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Row _buildLocationDescription(Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.location_on, color: Colors.red[800]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<String>(
              stream: order.deliveryLocationDescription,
              builder: (context, snap) {
                return Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 75),
                  child: Text(
                    snap.hasData ? snap.data : "Error",
                    style: FontHelper.regular14Black,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              },
            ),
            //TODO
            Text(
              '1.2km away',
              style: FontHelper.medium12TextStyle,
            )
          ],
        ),
      ],
    );
  }

  StreamBuilder _buildUser(Order order) {
    return StreamBuilder<User>(
      stream: order.creator
          .where((uid) => uid != null)
          .map((uid) => User.fromUID(uid)),
      builder: (context, user) {
        if (!user.hasData) return CircularProgressIndicator();

        return Row(
          children: <Widget>[
            StreamBuilder<String>(
              stream: user.data.thumbnailImage,
              builder: (context, user) {
                return CircleAvatar(
                  child: user.hasData
                      ? Image.network(user.data)
                      : Icon(Icons.person),
                  radius: 11.5,
                );
              },
            ),
            buildWidthBox(),
            StreamBuilder<String>(
              stream: user.data.name,
              builder: (context, user) {
                return Text(
                  user.hasData ? user.data : "Error",
                  style: FontHelper.semiBold16Black,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPickUpButton() {
    if (_pickUpButton) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: FlatButton(
          color: ColorHelper.dabaoOrange,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  child: Text(
                    "Pick Up",
                    style: FontHelper.semiBold14Black2,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            //TODO
          },
        ),
      );
    } else {
      return Offstage();
    }
  }

  SizedBox buildHeightBox() {
    return SizedBox(
      height: 8,
    );
  }

  SizedBox buildWidthBox() {
    return SizedBox(
      width: 10,
    );
  }
}

class ConfirmedTabView extends StatefulWidget {
  _ConfirmedTabViewState createState() => _ConfirmedTabViewState();
}

class _ConfirmedTabViewState extends State<ConfirmedTabView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('data'),
      ),
    );
  }
}

class MyRouteTabView extends StatefulWidget {
  _MyRouteTabViewState createState() => _MyRouteTabViewState();
}

class _MyRouteTabViewState extends State<MyRouteTabView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('data'),
      ),
    );
  }
}
