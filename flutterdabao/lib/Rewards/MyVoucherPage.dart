import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/OrderNow.dart';
import 'package:flutterdabao/CreateOrder/OverlayPages/CheckoutPage.dart';
import 'package:flutterdabao/CustomWidget/CustomDecorations.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Model/Voucher.dart';
import 'package:flutterdabao/Rewards/SearchPromoCodePage.dart';
import 'package:flutterdabao/Rewards/VoucherCell.dart';


class VoucherApplicationPage extends StatelessWidget {

  final MutableProperty<Voucher> voucherProperty;

  VoucherApplicationPage({
    Key key, @required this.voucherProperty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: <Widget>[
              Container(
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SearchPromoCodePage()));
                    },
                    child: Image.asset(
                      "assets/icons/search_icon.png",
                      color: Colors.black,
                    )),
              ),
            ],
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                size: 26,
                color: Colors.black,
              ),
            ),
            elevation: 0.0,
            title: Text(
              'My Vouchers',
              style: FontHelper.header3TextStyle,
            ),
          ),
          body: MyVoucherPage(
            onCompletionCallback: (Voucher voucher) {
              voucherProperty.value = voucher;
              Navigator.of(context).pop();
            },
          ),
        );
  }
}


class MyVoucherPage extends StatefulWidget {

  final Function(Voucher) onCompletionCallback;

  MyVoucherPage({Key key, @required this.onCompletionCallback, }) : super(key: key);

  _MyVoucherPageState createState() => _MyVoucherPageState();
}

class _MyVoucherPageState extends State<MyVoucherPage>
    with AutomaticKeepAliveClientMixin<MyVoucherPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
        child: _buildBody(context), color: ColorHelper.dabaoOffWhiteF5);
  }

  StreamBuilder _buildBody(BuildContext context) {
    return StreamBuilder<List<Voucher>>(
      stream: ConfigHelper
          .instance.currentUserProperty.value.listOfAvalibleVouchers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Offstage();
        return _buildList(snapshot.data);
      },
    );
  }

  _buildList(List<Voucher> listOfVouchers) {
    List<Object> listObject = List();

    listObject.addAll(listOfVouchers);
    listObject.add(ConfigHelper.instance.currentUserProperty.value);

    return ListView.builder(
      itemCount: listObject.length,
      itemBuilder: (BuildContext context, int index) {
        if (listObject[index] is User) {
          User user = listObject[index] as User;

          return Container(
            margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
            color: Colors.white,
            height: 100,
            child: FutureBuilder<Uri>(
              future: user.referalLink(),
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) return Offstage();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "Need more PromoCodes?\nInvite your friends with your Referal Code!",
                      style: FontHelper.bold(ColorHelper.dabaoOffBlack9B, 14),
                      textAlign: TextAlign.center,
                    ),
                    Text(snapshot.data.toString().replaceRange(0, 28, ""),
                        style: FontHelper.bold16Black),
                  ],
                );
              },
            ),
          );
        } else {
          return VoucherCell(
            voucher: listObject[index],
            mode: VoucherCellMode.apply,
            mainButtonTapped: widget.onCompletionCallback,
          );
        }
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
