import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/CustomDecorations.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Model/Voucher.dart';

class MyVoucherPage extends StatefulWidget {
  const MyVoucherPage({Key key}) : super(key: key);

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

    return Scaffold(body: _buildBody(context));
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

          

        } else {
          return VoucherCell(voucher: listObject[index]);
        }
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class VoucherCell extends StatefulWidget {
  final Voucher voucher;

  const VoucherCell({Key key, @required this.voucher}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VoucherCellState();
  }
}

class VoucherCellState extends State<VoucherCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0),
      child: PhysicalShape(
        elevation: 6.0,
        clipper: TriangleClipper(),
        child: new Container(
          margin: new EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 5.0),
                      child: StreamBuilder(
                        stream: widget.voucher.title,
                        builder: (context, snap) {
                          return Text(snap.hasData ? snap.data : "Error",
                              style: FontHelper.bold(
                                  ColorHelper.dabaoOffBlack4A, 18.0));
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(7.0, 5.0, 7.0, 7.0),
                        child: StreamBuilder(
                          stream: widget.voucher.description,
                          builder: (context, snap) {
                            return Text(snap.hasData ? snap.data : "Error",
                                style: FontHelper.bold(
                                    ColorHelper.dabaoOffGreyD3, 12.0));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                height: 1,
                foregroundDecoration: DottenLineDecoration(),
              ),
              Container(
                height: 95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(7.0, 15.0, 7.0, 0.0),
                      child: StreamBuilder<String>(
                        stream: widget.voucher.type,
                        builder: (context, snap) {
                          return Text(
                              snap.hasData ? snap.data.toUpperCase() : "Error",
                              style: FontHelper.bold(Colors.black, 12.0));
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(7.0, 3.0, 7.0, 0),
                      child: StreamBuilder<DateTime>(
                        stream: widget.voucher.expiryDate,
                        builder: (context, snap) {
                          return Text(
                              snap.hasData
                                  ? DateTimeHelper.convertDateTimeToDate(
                                      snap.data)
                                  : "",
                              style: FontHelper.bold(Colors.black, 10.0));
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 7.0, right: 7.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            RaisedButton(
                              padding: EdgeInsets.all(0),
                              elevation: 0.0,
                              highlightElevation: 0.0,
                              color: Colors.white,
                              child: Text(
                                'Remove',
                                textAlign: TextAlign.center,
                                style: FontHelper.bold(Colors.black, 12.0),
                              ),
                              onPressed: () {},
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                side: BorderSide(
                                    color: ColorHelper.dabaoOffBlack9B),
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 20.0),
                            ),
                            Expanded(
                              child: RaisedButton(
                                padding: EdgeInsets.all(0),
                                elevation: 3.0,
                                highlightElevation: 0.0,
                                color: ColorHelper.dabaoOrange,
                                child: Text(
                                  'Apply Now',
                                  textAlign: TextAlign.center,
                                  style: FontHelper.bold(Colors.white, 12.0),
                                ),
                                onPressed: () {},
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        color: Colors.white,
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0.0, 8.0);
    path.quadraticBezierTo(1.3, 1.3, 8, 0);
    path.lineTo(size.width - 8, 0.0);
    path.quadraticBezierTo(size.width - 1.3, 1.3, size.width, 8);
    path.lineTo(size.width, (size.height / 2) - 7);
    path.lineTo(size.width - 7, (size.height / 2));
    path.lineTo(size.width, (size.height / 2) + 7);
    path.lineTo(size.width, size.height - 8);
    path.quadraticBezierTo(
        size.width - 1.3, size.height - 1.3, size.width - 8, size.height);
    path.lineTo(8.0, size.height);
    path.quadraticBezierTo(1.3, size.height - 1.3, 0.0, size.height - 8);
    path.lineTo(0.0, (size.height / 2) + 7);
    path.lineTo(7, (size.height / 2));
    path.lineTo(0.0, (size.height / 2) - 7);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
