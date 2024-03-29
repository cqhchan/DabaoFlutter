import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Balance/Transaction.dart';
import 'package:flutterdabao/Chat/ChatNavigationButton.dart';
import 'package:flutterdabao/Chat/Inbox.dart';
import 'package:flutterdabao/CreateOrder/OrderNow.dart';
import 'package:flutterdabao/CreateRoute/RouteOverview.dart';
import 'package:flutterdabao/CustomWidget/Headers/FloatingHeader.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Home/BalanceCard.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Promotion.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:flutterdabao/Profile/Personal.dart';
import 'package:flutterdabao/Rewards/RewardsTab.dart';
import 'package:flutterdabao/ViewOrders/ViewOrderListPage.dart';
import 'package:flutterdabao/ViewOrdersTabPages/TabBarPage.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutterdabao/Holder/RouteHolder.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> with AutomaticKeepAliveClientMixin {
  ScrollController _controller = ScrollController();
  PageController controller;
  int currentpage = 0;
  MutableProperty<double> _opacityProperty = MutableProperty(0.0);
  _Home() {
    _controller.addListener(() {
      _opacityProperty.value =
          math.max(math.min((_controller.offset / 150.0), 1.0), 0.0);
    });
  }

  @override
  void initState() {
    super.initState();
    controller = new PageController(
      initialPage: currentpage,
      keepPage: false,
      viewportFraction: 0.8,
    );

    ConfigHelper.instance.startListeningToCurrentLocation(
        LocationHelper.instance.softAskForPermission());
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: ColorHelper.dabaoOffWhiteF5,
      appBar: buildAppBar(),
      drawer: buildDrawer(context),
      body: Column(children: <Widget>[
        Expanded(
          child: ListView(
            controller: _controller,
            children: <Widget>[
              //First Widget consisting of Bg, and balance
              _ActiveOrderCard(),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: Text(
                  "What would you like today?",
                  style: FontHelper.bold(Colors.black, 18),
                ),
                padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 30.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 25,
                  spacing: 25.0,
                  children: <Widget>[
                    //Dabaoee

                    squardCard(
                        'assets/images/dabaoee_splash.png',
                        'assets/icons/person.png',
                        'Dabaoee',
                        'I want to Order', () {
                      OrderHolder holder = OrderHolder();
                      if (Platform.isIOS)
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (_) => new OrderNow(
                                      holder: holder,
                                    ),
                                maintainState: false));
                      else {
                        Navigator.push(
                          context,
                          FadeRoute(
                              widget: OrderNow(
                            holder: holder,
                          )),
                        );
                      }
                    }),
                    //Dabaoer
                    squardCard(
                        'assets/images/dabaoer_splash.png',
                        'assets/icons/bike.png',
                        'Dabaoer',
                        'I want to Deliver', () {
                      RouteHolder holder = RouteHolder();

                      if (Platform.isIOS)
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (_) => new RouteOverview(
                                      holder: holder,
                                    ),
                                maintainState: false));
                      else {
                        Navigator.push(
                          context,
                          FadeRoute(widget: RouteOverview(holder: holder)),
                        );
                      }
                    }),
                  ],
                ),
              ),
              balanceCardStream(context),
              SizedBox(height: 20),

              StreamBuilder<List<Promotion>>(
                  stream:
                      ConfigHelper.instance.currentPromotionsProperty.producer,
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.data.length == 0) {
                      return Offstage();
                    }
                    return Container(
                      height: 210,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text(
                                "What's happening at Dabao?",
                                style: FontHelper.bold(Colors.black, 18.0),
                              )),
                          SizedBox(
                            height: 15,
                          ),
                          Expanded(
                            child: PageView.builder(
                                itemCount: snapshot.data.length,
                                onPageChanged: (value) {
                                  setState(() {
                                    currentpage = value;
                                  });
                                },
                                controller: controller,
                                itemBuilder: (context, index) =>
                                    promoNewsBuilder(
                                        index, snapshot.data[index])),
                          ),
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
        StreamBuilder<int>(
          stream: Observable.combineLatest3<List<DabaoRoute.Route>, List<Order>,
                  List<Order>, int>(
              ConfigHelper.instance.currentUserRoutesPastDayProperty.producer
                  .map((routes) {
                List<DabaoRoute.Route> temp = List.from(routes);

                temp.removeWhere((route) =>
                    route.status.value != DabaoRoute.routeStatus_Open);
                return temp;
              }),
              ConfigHelper.instance.currentUserDeliveredCompletedOrdersProperty
                  .producer,
              ConfigHelper
                  .instance.currentUserDeliveringOrdersProperty.producer,
              (routes, completed, deliverying) {
                return routes.length + completed.length + deliverying.length;
              }),
          builder: (context, snap) {
            if (!snap.hasData || snap.data == 0)
              return Container();
            else
              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(SlideUpRoute(widget: TabBarPage()));
                },
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                        color: ColorHelper.dabaoOrange,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0.0, 1.0),
                            color: Colors.grey,
                            blurRadius: 5.0,
                          )
                        ]),
                    child: SafeArea(
                      top: false,
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StreamBuilder<List>(
                                stream: ConfigHelper
                                    .instance
                                    .currentUserDeliveringOrdersProperty
                                    .producer,
                                builder: (BuildContext context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data.length == 0)
                                    return Text(
                                      "View Active Deliveries",
                                      style:
                                          FontHelper.semiBold(Colors.black, 14),
                                    );

                                  return Text(
                                    "View Active Deliveries (${snapshot.data.length})",
                                    style:
                                        FontHelper.semiBold(Colors.black, 14),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    height: 19.0,
                                    width: 24.0,
                                    child: Transform(
                                      transform: Matrix4.rotationZ(math.pi / 2),
                                      child: Icon(Icons.arrow_back_ios),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
          },
        )
      ]),
    );
  }

  promoNewsBuilder(int index, Promotion promotion) {
    return Container(
        margin: EdgeInsets.only(right: 25.0, bottom: 10.0),
        height: 180,
        child: Container(
          child: RaisedButton(
            color: Colors.white,
            padding: EdgeInsets.all(0),
            elevation: 4.0,
            disabledElevation: 4.0,
            highlightElevation: 4.0,
            onPressed: () {
              Navigator.of(context).push(FadeRoute(
                widget: WebviewScaffold(
                  url: promotion.promoURL.value,
                  appBar: new AppBar(
                    backgroundColor: Colors.white,
                    title: new Text(promotion.title.value),
                  ),
                ),
              ));
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: new FractionallySizedBox(
              widthFactor: 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0)),
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: CachedNetworkImageProvider(
                              promotion.imageURL.value,
                            ),
                          )),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    height: 40,
                    child: Text(
                      promotion.title.value,
                      style: FontHelper.semiBold(Colors.black, 14.0),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(right: 5.0),
                      height: 20.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "View Details",
                            style: FontHelper.bold(
                                ColorHelper.dabaoOffBlack4A, 10.0),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15.0,
                            color: ColorHelper.dabaoOffGrey70,
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ));
  }

  SizedBox buildDrawer(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Image.asset("assets/images/side_bar_splash.png",
                          fit: BoxFit.fill)),
                  SafeArea(
                    child: Container(
                      margin: EdgeInsets.only(top: 20, left: 20),
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Personal()),
                          );
                        },
                        child: Column(
                          children: <Widget>[
                            StreamBuilder<String>(
                              stream: ConfigHelper.instance.currentUserProperty
                                  .value.thumbnailImage,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Container(
                                    height: 62,
                                    width: 62,
                                    child: Image.asset(
                                      'assets/icons/profile_icon.png',
                                    ),
                                  );
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: ColorHelper.dabaoOrange)),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(snapshot.data),
                                    radius: 60,
                                  ),
                                );
                              },
                            ),
                            StreamBuilder<String>(
                              stream: ConfigHelper
                                  .instance.currentUserProperty.producer
                                  .switchMap((user) {
                                if (user == null) return Observable.just("");
                                return user.name;
                              }),
                              builder: (context, snap) {
                                if (!snap.hasData) return Offstage();
                                return Container(
                                  padding:
                                      EdgeInsets.only(top: 10.0, left: 10.0),
                                  child: Text(
                                    "${snap.data}",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: FontHelper.semiBold(
                                        ColorHelper.dabaoOffBlack4A, 14),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 40),
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        height: 40,
                        margin: EdgeInsets.only(top: 20),
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'Inbox',
                          style: FontHelper.semiBold12Black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context, SlideUpRoute(widget: ChatPage()));
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        height: 40,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'History',
                          style: FontHelper.semiBold12Black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                            return ViewOrderListPage();
                          }),
                        );
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        height: 40,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'Dabao Balance',
                          style: FontHelper.semiBold12Black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return TransactionsPage();
                        }));
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        height: 40,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'DabaoRewards',
                          style: FontHelper.semiBold12Black,
                        ),
                      ),
                      onTap: () {
                        // Then close the drawer
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            FadeRoute(
                                widget: RewardsTabBarPage(
                              initalIndex: 1,
                            )));
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        height: 40,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'About Dabao',
                          style: FontHelper.semiBold12Black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(FadeRoute(
                          widget: WebviewScaffold(
                            url: "https://www.dabaoapp.sg/",
                            appBar: new AppBar(
                              title: new Text("About Dabao"),
                            ),
                          ),
                        ));
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        height: 40,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'FAQs',
                          style: FontHelper.semiBold12Black,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(FadeRoute(
                          widget: WebviewScaffold(
                            url: "https://www.dabaoapp.sg/faqs",
                            appBar: new AppBar(
                              title: new Text("FAQS"),
                            ),
                          ),
                        ));
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        height: 40,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'Contact Us',
                          style: FontHelper.semiBold12Black,
                        ),
                      ),
                      onTap: () async {
                        await launch(
                            "mailto:admin@dabaoapp.sg?subject=Contact%20Dabao&body=Hello%20Dabao%20Team,");
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: 40),
                        height: 40,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'Log Out',
                          style: FontHelper.semiBold12Black,
                        ),
                      ),
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                      },
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
      title: Text(
        "D A B A O",
        style: FontHelper.bold(Colors.black, 20.0),
      ),
      actions: <Widget>[ChatNavigationButton()],
    );
  }

  Widget squardCard(
    String imagePath,
    String iconPath,
    String title,
    String body,
    VoidCallback onPressed,
  ) {
    return RaisedButton(
      color: Colors.white,
      padding: EdgeInsets.all(0),
      elevation: 4.0,
      disabledElevation: 4.0,
      highlightElevation: 4.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      onPressed: onPressed,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: 180.0, minHeight: 180, maxWidth: 135.0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Flex(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 108,
                    child: Image.asset(imagePath, fit: BoxFit.fitHeight)),
                Expanded(
                  flex: 3,
                  child: Container(),
                ),
                Text(
                  title,
                  style: FontHelper.bold14Black,
                ),
                Text(
                  body,
                  style: FontHelper.regular(Colors.black, 12.0),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
              direction: Axis.vertical,
            ),
            Container(
                margin: EdgeInsets.only(top: 30),
                height: 44,
                width: 44,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: new Offset(0.0, 10.0),
                        blurRadius: 30.0,
                      )
                    ]),
                child: Image.asset(iconPath, fit: BoxFit.contain)),
          ],
        ),
      ),
    );
  }

  StreamBuilder balanceCardStream(BuildContext context) {
    return StreamBuilder<User>(
        stream: ConfigHelper.instance.currentUserProperty.producer,
        builder: (BuildContext context, user) {
          return BalanceCard(user, context);
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class _ActiveOrderCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ActiveOrderCardState();
  }
}

class _ActiveOrderCardState extends State<_ActiveOrderCard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
        stream: Observable.combineLatest4<List<Order>, List<Order>, List<Order>,
                List<Order>, List<Order>>(
            ConfigHelper.instance.currentUserAcceptedOrdersProperty.producer,
            ConfigHelper.instance.currentUserRequestedOrdersProperty.producer,
            ConfigHelper
                .instance.currentUserPastWeekCompletedOrdersProperty.producer,
            ConfigHelper.instance.currentUserPastWeekCanceledOrdersProperty
                .producer, (accepted, requested, completed, cancelled) {
          List<Order> tempAccepted = List.from(accepted);
          List<Order> tempRequested = List.from(requested);
          List<Order> tempCompleted = List.from(completed);
          List<Order> tempCancelled = List.from(cancelled);

          tempAccepted.sort((lhs, rhs) =>
              rhs.deliveryTime.value.compareTo(lhs.deliveryTime.value));
          tempRequested.sort((lhs, rhs) => rhs.startDeliveryTime.value
              .compareTo(lhs.startDeliveryTime.value));

          tempCompleted.sort((lhs, rhs) =>
              rhs.completedTime.value.compareTo(lhs.completedTime.value));

          tempCompleted.removeWhere((order) {
            return order.completedTime.value
                .isBefore(DateTime.now().subtract(Duration(hours: 5)));
          });

          tempCancelled.removeWhere((order) {
            return order.startDeliveryTime.value
                .isBefore(DateTime.now().subtract(Duration(hours: 8)));
          });

          tempAccepted.addAll(tempRequested);
          tempAccepted.addAll(tempCompleted);
          tempAccepted.addAll(tempCancelled);

          return tempAccepted;
        }),
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null || snap.data.length == 0)
            return Offstage();

          // creating the list of widgets
          List<Widget> listOfWidget = List();

          listOfWidget.add(headerWidget(ConfigHelper
                  .instance.currentUserAcceptedOrdersProperty.value.length +
              ConfigHelper
                  .instance.currentUserRequestedOrdersProperty.value.length));
          listOfWidget.add(Line(
            color: ColorHelper.dabaoOrange,
            size: 2.0,
          ));
          snap.data.take(2).forEach((order) {
            listOfWidget.add(_OrderCell(order: order));
            listOfWidget.add(Line());
          });

          // adding the view all
          listOfWidget.add(buildViewAll());

          return Card(
              margin: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              child: Column(
                children: listOfWidget,
              ));
        });
  }

  Widget headerWidget(int numberOfActiveOrder) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
        child: Text(
          "Active Orders (${numberOfActiveOrder})",
          style: FontHelper.bold(Colors.black, 14),
        ),
      ),
    );
  }

  Widget buildViewAll() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return ViewOrderListPage();
            }),
          );
        },
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "View",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: ColorHelper.dabaoOffGrey70),
              ),
              SizedBox(
                width: 3,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: ColorHelper.dabaoOffGrey70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCell extends StatefulWidget {
  final Order order;

  const _OrderCell({Key key, this.order}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OrderCellState();
  }
}

class _OrderCellState extends State<_OrderCell> with HavingSubscriptionMixin {
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  @override
  void initState() {
    super.initState();

    listOfOrderItems = widget.order.orderItem;
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return orderCell(widget.order);
  }

  Widget orderCell(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) {
            return ViewOrderListPage();
          }),
        );
      },
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(left: 10, right: 5, top: 5),
        height: 55,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  foodTagHeader(order),
                  orderItemAndPrice(order)
                ],
              ),
            ),
            Container(
              width: 120,
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 3),
                      child: deliveryTime(order)),
                  status(order)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<String> foodTagHeader(Order order) {
    return StreamBuilder<String>(
        stream: order.foodTag,
        builder: (context, snap) {
          return Text(
            (snap.hasData && snap.data != null)
                ? StringHelper.upperCaseWords(snap.data)
                : "Error",
            style: FontHelper.semiBold14Black,
          );
        });
  }

  Expanded status(Order order) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.only(bottom: 3),
          child: StreamBuilder<String>(
            stream: order.status,
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Offstage();
              }

              switch (snapshot.data) {
                case orderStatus_Accepted:
                  return Container(
                    height: 19,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: ColorHelper.dabaoOrange,
                    ),
                    child: Center(
                      child: Text(
                        "Enroute",
                        style: FontHelper.semiBold12Black,
                      ),
                    ),
                  );
                case orderStatus_Requested:
                  return Container(
                    height: 19,
                    width: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color.fromRGBO(0x95, 0x9D, 0xAD, 1.0)),
                    child: Center(
                      child: Text("Pending",
                          style: FontHelper.semiBold(Colors.white, 12.0)),
                    ),
                  );
                case orderStatus_Completed:
                  return Container(
                    height: 19,
                    width: 60,
                    child: Center(
                      child: Text("Delivered",
                          style: FontHelper.semiBold(
                              ColorHelper.dabaoOffGreyD3, 12.0)),
                    ),
                  );
                case orderStatus_Cancelled:
                  return Container(
                    height: 19,
                    width: 60,
                    child: Center(
                      child: Text("Cancelled",
                          style: FontHelper.semiBold(
                              ColorHelper.dabaoOffGreyD3, 12.0)),
                    ),
                  );
                default:
                  return Offstage();
              }
            },
          ),
        ),
      ),
    );
  }

  StreamBuilder<String> deliveryTime(Order order) {
    return StreamBuilder<String>(
      stream: order.status.switchMap((status) {
        switch (status) {
          case orderStatus_Accepted:
            return order.deliveryTime.map((date) => date == null
                ? "Error"
                : DateTimeHelper.convertTimeToDisplayString(date));

          case orderStatus_Requested:
            return order.mode.switchMap((mode) {
              switch (mode) {
                case OrderMode.asap:
                  return BehaviorSubject(seedValue: "ASAP");
                case OrderMode.scheduled:
                  return Observable.combineLatest2(
                      order.startDeliveryTime, order.endDeliveryTime,
                      (start, end) {
                    if (start == null || end == null) return "Error";

                    return DateTimeHelper.convertDoubleTimeToDisplayString(
                        start, end);
                  });
              }
            });

          case orderStatus_Cancelled:
            return BehaviorSubject(seedValue: "");
          case orderStatus_Completed:
            return order.completedTime.map((date) => date == null
                ? "Error"
                : DateTimeHelper.convertTimeToDisplayString(date));

          default:
            return BehaviorSubject(seedValue: null);
        }
      }),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Offstage();
        }
        return Text(
          snapshot.data,
          style: FontHelper.semiBold(ColorHelper.dabaoOffBlack9B, 10.0),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  StreamBuilder<List<OrderItem>> orderItemAndPrice(Order order) {
    return StreamBuilder<List<OrderItem>>(
        stream: listOfOrderItems.producer,
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null || snap.data.length == 0)
            return Offstage();

          int totalItems = snap.data
              .map((orderItem) => orderItem.quantity.value)
              .reduce((lhs, rhs) => lhs + rhs);

          double totalPrice = snap.data
              .map((orderItem) =>
                  orderItem.quantity.value * orderItem.price.value)
              .reduce((lhs, rhs) => lhs + rhs);

          return Text(
            "Your Order: ${totalItems} items • ${StringHelper.doubleToPriceString(totalPrice)}",
            style: FontHelper.regular(ColorHelper.dabaoOffBlack9B, 12.0),
          );
        });
  }
}
