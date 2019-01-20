import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/ChatNavigationButton.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/Transact.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Model/Wallet.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';

class TransactionsPage extends StatefulWidget {
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<TransactionsPage>
    with HavingSubscriptionMixin, AutomaticKeepAliveClientMixin {
  MutableProperty<Wallet> currentUserWallet =
      ConfigHelper.instance.currentUserWalletProperty;

  MutableProperty<User> currentUser = ConfigHelper.instance.currentUserProperty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorHelper.dabaoOffWhiteF5,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: <Widget>[ChatNavigationButton(bgColor: Colors.white)],
        centerTitle: true,
        title: Text('Dabao Balance (SGD)',
            style: FontHelper.semiBold(Colors.black, 18.0)),
      ),
      body: _buildTransactionPage(),
    );
  }

  Widget _buildTransactionPage() {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 15,
        ),
        Line(),
        Container(
          color: Colors.white,
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              _buildCurrentBalance(),
              Container(
                height: 60,
                width: 1.0,
                color: Color(0x11000000),
              ),
              _buildInWithdrawalThisWeek(),
            ],
          ),
        ),
        Divider(
          height: 0,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Transactions',
            style: FontHelper.regular14Black,
          ),
        ),
        Divider(
          height: 0,
        ),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildCurrentBalance() {
    return Expanded(
      child: Container(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: StreamBuilder<double>(
              stream: currentUserWallet.producer.switchMap((wallet) => wallet ==
                      null
                  ? null
                  : Observable.combineLatest2<double, double, double>(
                      (wallet.currentValue), (wallet.inWithdrawal),
                      (currentValue, inWithdrawalValue) {
                      if (currentValue != null && inWithdrawalValue != null) {
                        return currentValue - inWithdrawalValue;
                      }
                      return 0.0;
                    })),
              builder: (context, snap) {
                if (!snap.hasData)
                  return Column(
                    children: <Widget>[
                      Text(
                        "\$0.00",
                        style: FontHelper.semiBold14Black,
                      ),
                      Text(
                        'Current Balance',
                        style: FontHelper.semiBold14Black,
                      ),
                    ],
                  );
                print('Current balance: ${snap.data}');
                return Column(
                  children: <Widget>[
                    Text(
                      StringHelper.doubleToPriceString(snap.data),
                      style: FontHelper.semiBold14Black,
                    ),
                    Text(
                      'Current Balance',
                      style: FontHelper.semiBold14Black,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
//TODO p2 update transactions types

  Widget _buildInWithdrawalThisWeek() {
    return Expanded(
      child: Container(
        // padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<double>(
          stream: currentUserWallet.producer.switchMap((wallet) {
            if (wallet == null) return Observable.just(null);
            return wallet.inWithdrawal;
          }),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "\$0.00",
                    style: FontHelper.semiBold14Black,
                  ),
                  Text(
                    'Pending Withdrawal',
                    style: FontHelper.semiBold14Black,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }
            return Column(
              children: <Widget>[
                Text(
                  StringHelper.doubleToPriceString(snapshot.data),
                  style: FontHelper.semiBold14Black,
                ),
                Text(
                  'Pending Withdrawal',
                  style: FontHelper.semiBold14Black,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Expanded(
      child: StreamBuilder<List<Transact>>(
          stream: currentUserWallet.producer.switchMap((wallet) =>
              wallet == null ? null : wallet.listOfTransactions.producer),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: Text('Please Check Your Connection'));
            if (snapshot.data.length == 0)
              return Center(
                child: Text("You have no transactions this week"),
              );
            List<Transact> temp = List.from(snapshot.data);
            temp.sort((lhs, rhs) =>
                rhs.createdDate.value.compareTo(lhs.createdDate.value));
            if (snapshot.hasData) {
              return _buildTransactList(temp);
            }
          }),
    );
  }
  //TODO p2 change name

  Widget _buildTransactList(List<Transact> list) {
    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      children: list.map((data) => _buildTransactCell(data)).toList(),
    );
  }

  Widget _buildTransactCell(Transact data) {
    print('---${data.type.value}');

    switch (data.type.value) {
      case 'REWARD':
        return _buildReward(data);
        break;
      case 'PAYMENT':
        return _buildPayment(data);
        break;
      case 'WITHDRAWAL':
        return _buildWithdrawal(data);
        break;
    }
    return Offstage();
  }

  Widget _buildReward(Transact data) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          height: 80,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Dabao PTE LTD",
                  style: FontHelper.regular10Black,
                ),
                StreamBuilder(
                  stream: data.rewardTitle,
                  builder: (context, snap) {
                    if (snap.data == null) return Offstage();
                    return Text(
                      "Reward:" + snap.data,
                      style: FontHelper.semiBold(Colors.black, 16),
                    );
                  },
                ),
                Text(
                  "",
                  style: FontHelper.regular10Black,
                ),
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder(
                  stream: data.createdDate,
                  builder: (context, snap) {
                    if (snap.data == null) return Offstage();
                    return Text(
                      DateTimeHelper.convertTimeToDisplayString(snap.data),
                      style: FontHelper.semiBold(Colors.black, 10),
                    );
                  },
                ),
                StreamBuilder(
                  stream: data.amount,
                  builder: (context, snap) {
                    if (snap.data == null) return Offstage();
                    return Text(
                      "+" + StringHelper.doubleToPriceString(snap.data),
                      style: FontHelper.semiBold(Colors.black, 14),
                    );
                  },
                ),
                Text(
                  "",
                  style: FontHelper.regular10Black,
                ),
              ],
            ),
          ]),
        ),
        Line()
      ],
    );
  }

  Widget _buildPayment(Transact data) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          height: 80,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                StreamBuilder<String>(
                    stream: data.orderID.switchMap(
                      (orderID) => orderID == null
                          ? null
                          : Order.fromUID(orderID)
                              .creator
                              .where((uid) => uid != null)
                              .switchMap((creatorID) {
                              return creatorID == null
                                  ? null
                                  : User.fromUID(creatorID).name;
                            }),
                    ),
                    builder: (context, snap) {
                      if (!snap.hasData) return Offstage();
                      return Text(
                        snap.data,
                        style: FontHelper.regular10Black,
                      );
                    }),
                Text(
                  "Payment",
                  style: FontHelper.semiBold(Colors.black, 16),
                ),
                Text(
                  "",
                  style: FontHelper.regular10Black,
                ),
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder(
                  stream: data.createdDate,
                  builder: (context, snap) {
                    if (snap.data == null) return Offstage();
                    return Text(
                      DateTimeHelper.convertTimeToDisplayString(snap.data),
                      style: FontHelper.semiBold(Colors.black, 10),
                    );
                  },
                ),
                StreamBuilder(
                  stream: data.amount,
                  builder: (context, snap) {
                    if (snap.data == null) return Offstage();
                    return Text(
                      "+" + StringHelper.doubleToPriceString(snap.data),
                      style: FontHelper.semiBold(Colors.black, 14),
                    );
                  },
                ),
                Text(
                  "",
                  style: FontHelper.regular10Black,
                ),
              ],
            ),
          ]),
        ),
        Line()
      ],
    );
  }

  Widget _buildWithdrawal(Transact data) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          height: 80,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                StreamBuilder<String>(
                    stream: currentUser.producer
                        .switchMap((user) => user == null ? null : user.name),
                    builder: (context, snap) {
                      if (!snap.hasData) return Offstage();
                      return Text(
                        snap.data,
                        style: FontHelper.regular10Black,
                      );
                    }),
                Text(
                  "Withdrawal",
                  style: FontHelper.semiBold(Colors.black, 16),
                ),
                StreamBuilder(
                    stream: data.withdrawalStatus,
                    builder: (context, snap) {
                      if (!snap.hasData)
                        return Text(
                          "",
                          style: FontHelper.regular10Black,
                        );
                      if (snap.data == Transact.pendingStatus)
                        return Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(0x95, 0x9D, 0xAD, 1.0),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "Pending",
                            style: FontHelper.semiBold(Colors.white, 12),
                          ),
                        );
                      if (snap.data == Transact.pendingStatus)
                        return Container(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                              color: ColorHelper.dabaoOffGreyD0,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "Completed",
                            style: FontHelper.semiBold(
                                ColorHelper.dabaoOffBlack9B, 12),
                          ),
                        );
                      return Text(
                        "",
                        style: FontHelper.regular10Black,
                      );
                    })
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder(
                  stream: data.createdDate,
                  builder: (context, snap) {
                    if (snap.data == null) return Offstage();
                    return Text(
                      DateTimeHelper.convertTimeToDisplayString(snap.data),
                      style: FontHelper.semiBold(Colors.black, 10),
                    );
                  },
                ),
                StreamBuilder(
                  stream: data.amount,
                  builder: (context, snap) {
                    if (snap.data == null) return Offstage();
                    return Text(
                      "-" + StringHelper.doubleToPriceString(snap.data),
                      style: FontHelper.semiBold(Colors.black, 14),
                    );
                  },
                ),
                Text(
                  "",
                  style: FontHelper.regular10Black,
                ),
              ],
            ),
          ]),
        ),
        Line()
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
