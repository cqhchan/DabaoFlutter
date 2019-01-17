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
import 'package:rxdart/rxdart.dart';

class VoucherApplicationPage extends StatelessWidget {
  final MutableProperty<Voucher> voucherProperty;

  VoucherApplicationPage({
    Key key,
    @required this.voucherProperty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
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

  MyVoucherPage({
    Key key,
    @required this.onCompletionCallback,
  }) : super(key: key);

  _MyVoucherPageState createState() => _MyVoucherPageState();
}

class _MyVoucherPageState extends State<MyVoucherPage>
    with AutomaticKeepAliveClientMixin<MyVoucherPage> {
  String searchText = 'Enter promo code to search voucher';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SearchPromoCodePage()));
          },
          child: Container(
            margin: EdgeInsets.all(8.0),
            height: 30.0,
            decoration: BoxDecoration(
                color: ColorHelper.rgbo(0xD0, 0xD0, 0xD0),
                borderRadius: BorderRadius.circular(5.0)),
            child: Row(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 7, right: 4),
                    child: Image.asset(
                      "assets/icons/search_icon.png",
                      color: ColorHelper.dabaoOffBlack9B,
                    )),
                Container(
                    padding: EdgeInsets.only(left: 4, right: 7),
                    child: Image.asset(
                      "assets/icons/Line 41.png",
                      color: ColorHelper.dabaoOffBlack9B,
                    )),
                Expanded(
                  child: Text(
                    searchText,
                    style: FontHelper.regular(Colors.black, 12.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: _buildBody(context),
        ),
      ],
    );
  }

  StreamBuilder _buildBody(BuildContext context) {
    return StreamBuilder<List<Voucher>>(
      stream: Observable.combineLatest2<List<Voucher>,List<Voucher>,List<Voucher>>(ConfigHelper
          .instance.currentUserProperty.value.listOfAvalibleVouchers.producer, ConfigHelper
          .instance.currentUserProperty.value.listOfInUsedVouchers.producer, (avaliableV,inuse){
            List<Voucher> tempAvaliable = List.from(avaliableV);
            List<Voucher> temopInUse = List.from(inuse);

            tempAvaliable.sort((lhs,rhs) => rhs.expiryDate.value.compareTo(lhs.expiryDate.value));
            temopInUse.sort((lhs,rhs) => rhs.expiryDate.value.compareTo(lhs.expiryDate.value));

            tempAvaliable.addAll(temopInUse);

            return tempAvaliable;

          }) ,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Offstage();
        return _buildList(snapshot.data);
      },
    );
  }

  _buildList(List<Voucher> listOfVouchers) {
    List<Object> listObject = List();

    listObject.addAll(listOfVouchers);
    //TODO p1 add in referral code
    // listObject.add(ConfigHelper.instance.currentUserProperty.value);

    return ListView.builder(
      shrinkWrap: true,
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
              future: user.referalLink,
              builder: (BuildContext context, snapshot) {
                if (!snapshot.hasData) return Offstage();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "Need more PromoCodes?\nInvite your friends with your Referral Code!",
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
  bool get wantKeepAlive => true;
}
