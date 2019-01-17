import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/CustomWidget/InputFormatter/CurrencyInputFormatter.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Wallet.dart';
import 'package:rxdart/rxdart.dart';

class SelectAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SelectAccountPageState();
  }
}

class _SelectAccountPageState extends State<SelectAccountPage>
    with HavingSubscriptionMixin {
  MutableProperty<List<WithdrawalAccount>> listOfAccounts =
      MutableProperty(null);
  bool showSelectButton = false;
  WithdrawalAccount selectedWithdrawalAccount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription.add(listOfAccounts.bindTo(ConfigHelper
        .instance.currentUserWalletProperty.producer
        .switchMap((wallet) => wallet == null
            ? BehaviorSubject(seedValue: null)
            : wallet.listOfWithdrawalAccount.producer)));
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: ColorHelper.dabaoOffWhiteF5,
            title: Text(
              "Dabao Credits",
              style: FontHelper.regular(Colors.black, 18.0),
            )),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Balance(
              bgColor: ColorHelper.dabaoOffWhiteF5,
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            padding: EdgeInsets.only(
                                top: 20.0, bottom: 5.0, left: 10, right: 10),
                            child: Text(
                                "Select a bank account to transfer your balance to:",
                                style: FontHelper.regular14Black)),
                      ),
                      Line(
                          color: ColorHelper.rgbo(0xD0, 0xD0, 0xD0),
                          margin: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          )),
                      StreamBuilder<Wallet>(
                        stream: ConfigHelper
                            .instance.currentUserWalletProperty.producer,
                        builder: (context, snap) {
                          if (snap == null) return Offstage();

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AddBankAccountPage(
                                        wallet: snap.data,
                                      )));
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: Text("+ Add an account",
                                  style: FontHelper.regular(
                                      ColorHelper.dabaoOffBlack9B, 14.0)),
                            ),
                          );
                        },
                      ),
                      Line(
                        margin: EdgeInsets.only(left: 15, right: 15),
                      ),
                      buildAccounts()
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Offstage(
                      offstage: !showSelectButton ||
                          selectedWithdrawalAccount == null,
                      child: SafeArea(
                        child: Container(
                          margin: EdgeInsets.all(20),
                          height: 40,
                          child: RaisedButton(
                            disabledElevation: 0.0,
                            disabledColor: ColorHelper.dabaoOffGreyD0,
                            elevation: 4.0,
                            highlightElevation: 0.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 9.0),
                            color: ColorHelper.dabaoOrange,
                            child: Center(
                              child: Text("Select",
                                  style:
                                      FontHelper.semiBold(Colors.black, 14.0)),
                            ),
                            onPressed: () {
                              Selectable.deselectAll(listOfAccounts.value);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => WithdrawalPage(
                                        account: selectedWithdrawalAccount,
                                      )));
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      onWillPop: () {
        Selectable.deselectAll(listOfAccounts.value);
        return Future.value(true);
      },
    );
  }

  Expanded buildAccounts() {
    return Expanded(
      child: StreamBuilder<List<WithdrawalAccount>>(
        stream: listOfAccounts.producer,
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null)
            return Center(
                child: Container(
                    height: 20, width: 20, child: CircularProgressIndicator()));

          if (snapshot.data.length == 0) {
            return Align(
                alignment: Alignment(0.0, -0.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset("assets/icons/dabao_piggy.png"),
                    Text(
                      "You currently have no accounts to transfer to.\nDabao Piggy is feeling lonely :(",
                      style:
                          FontHelper.regular(ColorHelper.dabaoOffBlack9B, 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ));
          }

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return buildAccountCell(snapshot.data[index]);
            },
          );
        },
      ),
    );
  }

  Widget buildAccountCell(WithdrawalAccount account) {
    return GestureDetector(
      onTap: () {
        bool isSelected = account.isSelected;
        Selectable.deselectAll(listOfAccounts.value);
        account.isSelectedProperty.value = !isSelected;
        setState(() {
          selectedWithdrawalAccount = account;
          showSelectButton = account.isSelectedProperty.value;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(
          top: 10,
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StreamBuilder<String>(
                        stream: account.accountNickname,
                        builder: (context, snap) {
                          return Text(
                            snap.data == null ? "Untitled Account" : snap.data,
                            style: FontHelper.regular(
                                Color.fromRGBO(0x00, 0x3A, 0xF9, 1.0), 12.0),
                          );
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      StreamBuilder<String>(
                        stream: account.accountHoldername,
                        builder: (context, snap) {
                          return Text(
                            snap.data == null ? "Error" : snap.data,
                            style: FontHelper.regular(Colors.black, 12.0),
                          );
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      StreamBuilder<String>(
                        stream: account.bankName,
                        builder: (context, snap) {
                          return Text(
                            snap.data == null ? "Error" : snap.data,
                            style: FontHelper.regular(Colors.black, 12.0),
                          );
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      StreamBuilder<String>(
                        stream: account.accountNumber,
                        builder: (context, snap) {
                          return Text(
                            snap.data == null ? "Error" : snap.data,
                            style: FontHelper.regular(Colors.black, 12.0),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 20),
                  child: StreamBuilder<bool>(
                    stream: account.isSelectedProperty.producer,
                    builder: (BuildContext context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          !snapshot.data)
                        return Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorHelper.dabaoOrange,
                              width: 1.5,
                            ),
                          ),
                        );
                      else
                        return Icon(
                          Icons.check_circle,
                          color: ColorHelper.dabaoOrange,
                          size: 18,
                        );
                    },
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Line(
              margin: EdgeInsets.only(left: 10, right: 10),
            )
          ],
        ),
      ),
    );
  }
}

class WithdrawalPage extends StatefulWidget {
  final WithdrawalAccount account;

  const WithdrawalPage({Key key, @required this.account}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WithdrawalPageState();
  }
}

class WithdrawalPageState extends State<WithdrawalPage> {
  TextEditingController _priceController;
  String errorMessage = "";
  @override
  void initState() {
    _priceController = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: ColorHelper.dabaoOffWhiteF5,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(
            "Transfer Balance",
            style: FontHelper.bold(Colors.black, 16.0),
          ),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 2.0),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 1.5)
                      ]),
                      child: Balance(
                        bgColor: Colors.white,
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: SafeArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(bottom: 5.0),
                                    child: Text(
                                        "Step 1: Select an amount to withdraw (SGD)")),
                                CupertinoTextField(
                                  padding: EdgeInsets.fromLTRB(15, 6, 15, 6),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0)),
                                  controller: _priceController,
                                  textAlign: TextAlign.start,
                                  style: FontHelper.medium(Colors.black, 14.0),
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    CurrencyInputFormatter(),
                                  ],
                                  placeholder: "\$0.00",
                                  maxLines: 1,
                                ),
                                Container(
                                    margin:
                                        EdgeInsets.only(bottom: 5.0, top: 10.0),
                                    child: Text(
                                        "Step 2: Check destination account details")),
                                buildAccountCell(widget.account),
                                Container(
                                  padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
                                  child: Text(
                                    "Take note that all withdrawal processes from your Dabao balance will take approximately 1-3 working days. Contact us at support@dabao.com for any enquiries.",
                                    style: FontHelper.regular12Black,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      errorMessage,
                                      style: FontHelper.regular(
                                          ColorHelper.dabaoErrorRed, 12.0),
                                      textAlign: TextAlign.center,
                                    )),
                                Container(
                                  height: 40,
                                  child: RaisedButton(
                                    disabledElevation: 0.0,
                                    disabledColor: ColorHelper.dabaoOffGreyD0,
                                    elevation: 4.0,
                                    highlightElevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 9.0),
                                    color: ColorHelper.dabaoOrange,
                                    child: Center(
                                      child: Text("Confirm",
                                          style: FontHelper.semiBold(
                                              Colors.black, 14.0)),
                                    ),
                                    onPressed: () async {
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());

                                      if (_priceController.text == null ||
                                          _priceController.text.isEmpty) {
                                        setState(() {
                                          errorMessage =
                                              "Please enter an amount";
                                        });
                                      } else {
                                        double amount =
                                            StringHelper.stringPriceToDouble(
                                                _priceController.text);
                                        showLoadingOverlay(context: context);

                                        await FirebaseCloudFunctions
                                                .requestWithdrawal(
                                                    amount: amount,
                                                    userID: ConfigHelper
                                                        .instance
                                                        .currentUserProperty
                                                        .value
                                                        .uid,
                                                    account: widget.account)
                                            .then((isSuccessful) {
                                          if (isSuccessful) {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text("Success"),
                                                    content: Text(
                                                        "Your Dabao Balance has been updated"),
                                                  );
                                                });
                                          } else {
                                            Navigator.of(context).pop();
                                            final snackBar = SnackBar(
                                                content: Text(
                                                    'An Error has occured. Please check your network connectivity'));
                                            Scaffold.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                        }).catchError((error) {
                                          if (error is PlatformException) {
                                            PlatformException e = error;
                                            Navigator.of(context).pop();
                                            final snackBar = SnackBar(
                                                content: Text(e.message));
                                            Scaffold.of(context)
                                                .showSnackBar(snackBar);
                                          } else {
                                            Navigator.of(context).pop();
                                            final snackBar = SnackBar(
                                                content: Text(
                                                    'An Error has occured. Please check your network connectivity'));
                                            Scaffold.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                        });
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget buildAccountCell(WithdrawalAccount account) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<String>(
            stream: account.accountNickname,
            builder: (context, snap) {
              return Text(
                snap.data == null ? "Untitled Account" : snap.data,
                style: FontHelper.regular(
                    Color.fromRGBO(0x00, 0x3A, 0xF9, 1.0), 12.0),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<String>(
            stream: account.accountHoldername,
            builder: (context, snap) {
              return Text(
                snap.data == null ? "Error" : snap.data,
                style: FontHelper.regular(Colors.black, 12.0),
              );
            },
          ),
          SizedBox(
            height: 5,
          ),
          StreamBuilder<String>(
            stream: account.bankName,
            builder: (context, snap) {
              return Text(
                snap.data == null ? "Error" : snap.data,
                style: FontHelper.regular(Colors.black, 12.0),
              );
            },
          ),
          SizedBox(
            height: 5,
          ),
          StreamBuilder<String>(
            stream: account.accountNumber,
            builder: (context, snap) {
              return Text(
                snap.data == null ? "Error" : snap.data,
                style: FontHelper.regular(Colors.black, 12.0),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddBankAccountPage extends StatefulWidget {
  final Wallet wallet;

  const AddBankAccountPage({Key key, this.wallet}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddBankAccountPageState();
  }
}

class _AddBankAccountPageState extends State<AddBankAccountPage>
    with HavingSubscriptionMixin {
  TextEditingController accountNickName = TextEditingController();
  TextEditingController accountHolderName = TextEditingController();
  TextEditingController bank = TextEditingController();
  TextEditingController accountNumber = TextEditingController();

  String accountNameString = "";
  String bankString = "";
  String accountNumberString = "";
  String accountNicknameString = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    accountNickName.addListener(() {
      setState(() {
        if (accountNickName.text == null)
          accountNicknameString = "";
        else
          accountNicknameString = accountNickName.text;
      });
    });

    accountHolderName.addListener(() {
      setState(() {
        if (accountHolderName.text == null)
          accountNameString = "";
        else
          accountNameString = accountHolderName.text;
      });
    });
    bank.addListener(() {
      setState(() {
        if (bank.text == null)
          bankString = "";
        else
          bankString = bank.text;
      });
    });
    accountNumber.addListener(() {
      setState(() {
        if (accountNumber.text == null)
          accountNumberString = "";
        else
          accountNumberString = accountNumber.text;
      });
    });
  }

  @override
  void dispose() {
    accountNickName.dispose();
    accountHolderName.dispose();
    bank.dispose();
    accountNumber.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Add bank Account",
            style: FontHelper.bold(ColorHelper.dabaoOffPaleBlue, 16)),
        elevation: 0.0,
        backgroundColor: ColorHelper.dabaoOffWhiteF5,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 20, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.only(top: 20, right: 15, bottom: 5, left: 10),
                child: Text(
                  "Account Nickname (Optional)",
                  style: FontHelper.regular12Black,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: ColorHelper.dabaoGreyE0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: accountNickName,
                  style: FontHelper.regular(Colors.black, 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. My POSB Account',
                    hintStyle: TextStyle(color: ColorHelper.dabaoOffBlack9B),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: ColorHelper.dabaoGreyE0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: accountHolderName,
                  style: FontHelper.regular(Colors.black, 14),
                  decoration: InputDecoration(
                    hintText: 'Account Holder Name',
                    hintStyle: TextStyle(color: ColorHelper.dabaoOffBlack9B),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: ColorHelper.dabaoGreyE0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: bank,
                  style: FontHelper.regular(Colors.black, 14),
                  decoration: InputDecoration(
                    hintText: 'Bank',
                    hintStyle: TextStyle(color: ColorHelper.dabaoOffBlack9B),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                ),
                margin: EdgeInsets.only(bottom: 30.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    color: ColorHelper.dabaoGreyE0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: accountNumber,
                  style: FontHelper.regular(Colors.black, 14),
                  decoration: InputDecoration(
                    hintText: 'Enter Bank Account Number',
                    hintStyle: TextStyle(color: ColorHelper.dabaoOffBlack9B),
                    border: InputBorder.none,
                  ),
                ),
              ),
              RaisedButton(
                disabledElevation: 0.0,
                disabledColor: ColorHelper.dabaoOffGreyD0,
                elevation: 4.0,
                highlightElevation: 0.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 9.0),
                color: ColorHelper.dabaoOrange,
                child: Center(
                  child: Text("Confirm",
                      style: FontHelper.semiBold(
                          accountNameString.isNotEmpty &&
                                  accountNumberString.isNotEmpty &&
                                  bankString.isNotEmpty
                              ? Colors.black
                              : ColorHelper.dabaoOffBlack9B,
                          14.0)),
                ),
                onPressed: accountNameString.isNotEmpty &&
                        accountNumberString.isNotEmpty &&
                        bankString.isNotEmpty
                    ? () {
                        widget.wallet.addWithdrawalAccount(
                            accountNumberString,
                            bankString,
                            accountNameString,
                            accountNicknameString);
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
              Text(
                accountNameString.isNotEmpty &&
                        accountNumberString.isNotEmpty &&
                        bankString.isNotEmpty
                    ? "Note: Please ensure that your bank account details are entered accurately and clearly. Dabao will not be liable for any erroneous transfers arising from incorrectly entered account details."
                    : "Note: Dabao will only save your details so that you do not have to re-enter manually each time. This will not be linked to your bank account.",
                style: FontHelper.regular12Black,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      )),
    );
  }
}

class Balance extends StatelessWidget {
  final Color bgColor;

  const Balance({Key key, @required this.bgColor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: bgColor,
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Your Balance (SGD)", style: FontHelper.regular14Black),
          StreamBuilder<double>(
            stream: ConfigHelper.instance.currentUserWalletProperty.producer
                .switchMap((wallet) => wallet == null
                    ? BehaviorSubject(seedValue: 0.0)
                    : Observable.combineLatest2<double, double, double>(
                        (wallet.currentValue), (wallet.inWithdrawal),
                        (currentValue, inWithdrawalValue) {
                        if (currentValue != null && inWithdrawalValue != null) {
                          return currentValue - inWithdrawalValue;
                        }
                        return 0.0;
                      })),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData)
                return Text(
                  "\$0.00",
                  style: FontHelper.semiBold(Colors.black, 44),
                );

              return Text(StringHelper.doubleToPriceString(snapshot.data),
                  style: FontHelper.semiBold(Colors.black, 44));
            },
          )
        ],
      ),
    );
  }
}
