import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/ChatNavigationButton.dart';
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
      appBar: AppBar(
        actions: <Widget>[ChatNavigationButton(bgColor: ColorHelper.dabaoOrange,)],
        centerTitle: true,
        title: Text('Dabao Balance', style: FontHelper.header3TextStyle),
      ),
      body: _buildTransactionPage(),
    );
  }

  Widget _buildTransactionPage() {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            _buildCurrentBalance(),
            Container(
              height: 60,
              width: 1.0,
              color: Color(0x11000000),
            ),
            _buildEarnedThisWeek(),
          ],
        ),
        Divider(
          height: 0,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Transactions',
            style: FontHelper.regular10Black,
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

  Widget _buildEarnedThisWeek() {
    return Expanded(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder<double>(
            stream: currentUserWallet.producer.switchMap((wallet) {
              if (wallet == null) return Observable.just(null);
              return wallet.totalAmountEarnedThisWeek;
            }),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    Text(
                      "\$0.00",
                      style: FontHelper.semiBold14Black,
                    ),
                    Text(
                      'This Week',
                      style: FontHelper.semiBold14Black,
                    ),
                  ],
                );
              }
              print('Earned this week: ${snapshot.data}');
              return Column(
                children: <Widget>[
                  Text(
                    '+' + StringHelper.doubleToPriceString(snapshot.data),
                    style: FontHelper.semiBold14Black,
                  ),
                  Text(
                    'This Week',
                    style: FontHelper.semiBold14Black,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Expanded(
      child: StreamBuilder<List<Transact>>(
          stream: currentUserWallet.producer.switchMap(
              (wallet) => wallet == null ? null : wallet.listOfTransactions),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: Text('Please Check Your Connection'));
            if (snapshot.hasData) {
              return _buildTransactList(snapshot.data);
            }
          }),
    );
  }

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
        ListTile(
          isThreeLine: true,
          leading: StreamBuilder<User>(
            stream: currentUser.producer,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Image.asset(
                          'assets/icons/profile_icon.png',
                          fit: BoxFit.fill,
                        )),
                  ),
                );
              return FittedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data.thumbnailImage.value,
                      placeholder: GlowingProgressIndicator(
                        child: Icon(
                          Icons.image,
                          size: 50,
                        ),
                      ),
                      errorWidget: Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  StreamBuilder<User>(
                      stream: currentUser.producer,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Text('Dabao Buddy');
                        return Text(
                          snapshot.data.name.value,
                          style: FontHelper.regular10Black,
                        );
                      }),
                  Text(
                    DateTimeHelper.convertTimeToDisplayString(
                        data.createdDate.value),
                    style: FontHelper.semiBold10Grey,
                  )
                ],
              ),
            ],
          ),
          subtitle: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Reward Title: ' + data.rewardTitle.value,
                      style: FontHelper.semiBold16Black,
                    )),
              ),
              Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '+S' +
                          (StringHelper.doubleToPriceString(
                              data.amount.value * 1.0)),
                      style: FontHelper.semiBold14Black,
                    )),
              )
            ],
          ),
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }

  Widget _buildPayment(Transact data) {
    return StreamBuilder<User>(
        stream: data.orderID.switchMap(
          (orderID) => orderID == null
              ? null
              : Order.fromUID(orderID)
                  .creator
                  .where((uid) => uid != null)
                  .map((creatorID) {
                  return creatorID == null ? null : User.fromUID(creatorID);
                }),
        ),
        builder: (context, user) {
          if (!user.hasData || user.data == null) {
            return Offstage();
          } else if (user.hasData)
            return Column(
              children: <Widget>[
                ListTile(
                  isThreeLine: true,
                  leading: FittedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: user.data.thumbnailImage.value == null
                            ? Image.asset(
                                'assets/icons/profile_icon.png',
                                fit: BoxFit.fill,
                              )
                            : _buildAvatar(user),
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          StreamBuilder(
                            stream: user.data.name,
                            builder: (BuildContext context, snapshot) {
                              return Text(
                                !snapshot.hasData || snapshot.data == null
                                    ? 'Please try again'
                                    : snapshot.data,
                                style: FontHelper.regular10Black,
                              );
                            },
                          ),
                          Text(
                            DateTimeHelper.convertTimeToDisplayString(
                                data.createdDate.value),
                            style: FontHelper.semiBold10Grey,
                          )
                        ],
                      ),
                    ],
                  ),
                  subtitle: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: StreamBuilder<Order>(
                                stream: data.orderID
                                    .map((uid) => Order.fromUID(uid)),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data == null) return Offstage();
                                  return Text(
                                    snapshot.data.foodTag.value == null
                                        ? ''
                                        : StringHelper.upperCaseWords(
                                            snapshot.data.foodTag.value),
                                    style: FontHelper.semiBold16Black,
                                  );
                                })),
                      ),
                      Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  user.data.uid == currentUser.value.uid
                                      ? "-"
                                      : "+",
                                  style: FontHelper.semiBold14Black,
                                ),
                                Text(
                                  'S' +
                                      (StringHelper.doubleToPriceString(
                                          data.amount.value * 1.0)),
                                  style: FontHelper.semiBold14Black,
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                ),
                Divider(
                  height: 0,
                )
              ],
            );
        });
  }

  Widget _buildAvatar(user) {
    return FittedBox(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: SizedBox(
          height: 50,
          width: 50,
          child: StreamBuilder<String>(
            stream: user.data.thumbnailImage,
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) return GlowingProgressIndicator(
                child: Icon(
                  Icons.image,
                  size: 50,
                ),
              );

              return CachedNetworkImage(
              imageUrl: user.data.thumbnailImage.value,
              placeholder: GlowingProgressIndicator(
                child: Icon(
                  Icons.image,
                  size: 50,
                ),
              ),
              errorWidget: Icon(Icons.error),
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawal(Transact data) {
    return Column(
      children: <Widget>[
        ListTile(
          isThreeLine: true,
          leading: StreamBuilder<User>(
            stream: currentUser.producer,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Image.asset(
                          'assets/icons/profile_icon.png',
                          fit: BoxFit.fill,
                        )),
                  ),
                );
              return FittedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data.thumbnailImage.value,
                      placeholder: GlowingProgressIndicator(
                        child: Icon(
                          Icons.image,
                          size: 50,
                        ),
                      ),
                      errorWidget: Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  StreamBuilder<User>(
                      stream: currentUser.producer,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Text('Dabao Buddy');
                        return Text(
                          snapshot.data.name.value,
                          style: FontHelper.regular10Black,
                        );
                      }),
                  Text(
                    DateTimeHelper.convertTimeToDisplayString(
                        data.createdDate.value),
                    style: FontHelper.semiBold10Grey,
                  )
                ],
              ),
            ],
          ),
          subtitle: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Withdrawal',
                      style: FontHelper.semiBold16Black,
                    )),
              ),
              Expanded(
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '-S' +
                          (StringHelper.doubleToPriceString(
                              data.amount.value * 1.0)),
                      style: FontHelper.semiBold14Black,
                    )),
              )
            ],
          ),
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
