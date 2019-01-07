import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Transaction.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Model/Wallet.dart';
import 'package:rxdart/rxdart.dart';

class TransactionsPage extends StatefulWidget {
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<TransactionsPage> {
  MutableProperty<Wallet> currentUserWallet =
      ConfigHelper.instance.currentUserWalletProperty;

  User user = User.fromUID(ConfigHelper.instance.currentUserProperty.value.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dabao Balance', style: FontHelper.header3TextStyle),
      ),
      body: _buildTransactionPage(),
    );
  }

  Widget _buildTransactionPage() {
    return Column(
      children: <Widget>[
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            _buildCurrentBalance(),
            _buildEarnedThisWeek(),
          ],
        ),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildCurrentBalance() {
    return Expanded(
      child: StreamBuilder<double>(
          stream: currentUserWallet.producer.switchMap((wallet) =>
              wallet == null
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
              return Text(
                "\$0.00",
                style: FontHelper.semiBold16Black,
              );

            return Text(
              StringHelper.doubleToPriceString(snap.data),
              style: FontHelper.semiBold16Black,
            );
          }),
    );
  }

  Widget _buildEarnedThisWeek() {
    return StreamBuilder(
      stream: Observable(currentUserWallet.producer.switchMap(
        (wallet) => wallet == null
            ? Observable.just(null)
            : print
            // : wallet.listOfTransactions.map((convert) {
            //     print(convert);
            //     print('im here!!!!!');
            //     convert.forEach((f) {
            //       print(f.amount);
            //     });
            //     return Observable.just(convert);
            //   }),
      )),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text('no data');
        if (snapshot.hasData) return Text('has data');
      },
    );

    //     stream: currentUserWallet.producer.switchMap((wallet) {
    //   if (wallet == null) {
    //     print(wallet);
    //     print('-----------nothing------------');
    //   } else {
    //     // Observable(wallet.listOfTransactions).map((transactions){
    //     //           List<Transact> temp = List.from(transactions);
    //     //           int sum = 0;
    //     //           temp.removeWhere((data)=>data.type.value == 'WITHDRAWAL');
    //     //           temp.forEach((data){
    //     //             sum = sum + data.amount.value;
    //     //           });
    //     //           print(sum);
    //     //           return sum;
    //     print('-----------im herer------------');
    //     print(wallet.uid);
    //     print(wallet.listOfTransactions);
    //     wallet.listOfTransactions.map((transactions) {
    //       List<Transact> temp = List.from(transactions);
    //       int sum = 0;
    //       temp.removeWhere((data) => data.type.value == 'WITHDRAWAL');
    //       temp.forEach((data) {
    //         print(data.amount.value);
    //         sum = sum + data.amount.value;
    //       });
    //       print(sum);
    //       return Observable.just(sum);
    //     });
    //   }
    // }),
    //  builder: (context, snapshot) {
    //   if (!snapshot.hasData) return Text('no data');

    //   if (snapshot.hasData) {
    //     // print(snapshot.data['TYPE']);

    //     // print(snapshot.data);
    //     print('calculate here');
    //     print(snapshot.data);
    //     return Text('Got data');

    // print(snapshot.data);
    // return Text(snapshot.data.toString());
    // return _buildTransactList(snapshot.data.documents);
    // return new ListView(
    //   shrinkWrap: true,
    //   children: snapshot.data((document) {
    //     return new ListTile(
    //       title: new Text(document['TYPE']),
    //     );
    //   }).toList(),
    // );
  }

  Widget _buildTransactionList() {
    // return StreamBuilder<List<Transact>>(
    //     stream: currentUserWallet.producer.switchMap((wallet) => wallet == null
    //         ? null
    //         : Observable(wallet.listOfTransactions).map((transactions) {
    //             List<Transact> data = List.from(transactions);
    //             data.removeWhere(
    //                 (transaction) => transaction.type.value != 'REWARD');
    //             return data;
    //           })),
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('wallets')
            .document(ConfigHelper.instance.currentUserProperty.value.uid)
            .collection('statements')
            .document('2019_WEEK_01')
            .collection('transactions')
            // .document('DhYJvFDEVlrCvsVcw06X')
            // .where('TYPE', isEqualTo: 'REWARD')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('no data');

          if (snapshot.hasData) {
            // print(snapshot.data['TYPE']);

            // print(snapshot.data);
            print('here');

            // print(snapshot.data);
            // return Text(snapshot.data.toString());
            return _buildTransactList(snapshot.data.documents);
            // return new ListView(
            //   shrinkWrap: true,
            //   children: snapshot.data((document) {
            //     return new ListTile(
            //       title: new Text(document['TYPE']),
            //     );
            //   }).toList(),
            // );
          }
        });
  }

  Widget _buildTransactList(List<DocumentSnapshot> list) {
    // print(list.toString());
    // print(list.length);
    return ListView(
      shrinkWrap: true,
      // cacheExtent: 500.0 * list.length,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      // children: <Widget>[_buildTransactCell(list)],
      children: list.map((data) => _buildTransactCell(data)).toList(),
      // children: list.map(f),
    );
  }

  Widget _buildTransactCell(DocumentSnapshot data) {
    print('here1');
    print(data['TYPE']);

    switch (data['TYPE']) {
      case 'REWARD':
        return _buildReward(data);
        break;
      case 'PAYMENT':
        break;
      case 'WITHDRAWAL':
        break;
      case 'DEPOSIT':
        break;
    }
    return Offstage();
    // return Text('No data');
    // print(data.type);
    // return Text(data.toString());
    // return ListTile(
    //   leading: FittedBox(
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(50.0),
    //       child: SizedBox(
    //           height: 50,
    //           width: 50,
    //           child: Image.asset(
    //             'assets/icons/profile_icon.png',
    //             fit: BoxFit.fill,
    //           )),
    //     ),
    //   ),
    //   trailing: Text(data['Amount'].toString()),
    // );
    // return StreamBuilder(
    //   stream: data,
    //   builder: (context, snapshot) {
    //     // print(snapshot.data['TYPE']);
    //     return Text(snapshot.data.toString());
    //   },
    // );
  }

  _buildReward(data) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          leading: FittedBox(
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
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  StreamBuilder(
                      // stream: Firestore.instance
                      //     .collection('users')
                      //     .document(otherUser)
                      //     .snapshots(),
                      builder: (context, snapshot) {
                    if (!snapshot.hasData) return Offstage();
                    return Text(
                      snapshot.data['N'] != null ? snapshot.data['N'] : '',
                      style: FontHelper.regular10Black,
                    );
                  }),
                  // Text(
                  //   DateTimeHelper.convertTimeToDisplayString(
                  //       channel.lastSent.value),
                  //   style: FontHelper.semiBold10Grey,
                  // )
                  Text(
                    DateTimeHelper.convertEpochSecondsToDateTimeString(
                        data['CreatedDate'].seconds),
                    style: FontHelper.semiBold10Grey,
                  )
                ],
              ),
              StreamBuilder(
                  // stream: Firestore.instance
                  //     .collection('orders')
                  //     .document(channel.orderUid.value)
                  //     .snapshots()
                  //     .map((snapshot) => snapshot.data),
                  builder: (context, snapshot) {
                if (!snapshot.hasData) return Offstage();
                return Text(
                  snapshot.data['FT'] != null
                      ? StringHelper.upperCaseWords(snapshot.data['FT'])
                      : 'Order Deleted',
                  style: FontHelper.semiBold16Black,
                );
              }),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 100, 0),
            child: Text(data['rewardTitle']),
          ),
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }
}
