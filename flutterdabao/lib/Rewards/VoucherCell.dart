import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/CustomDecorations.dart';
import 'package:flutterdabao/CustomWidget/CustomDialogs.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/Voucher.dart';

enum VoucherCellMode { redeem, apply }

class VoucherCell extends StatefulWidget {
  final Voucher voucher;
  final VoucherCellMode mode;
  final Function(Voucher) mainButtonTapped;
  final Function(Voucher) secondaryButtonTapped;

  const VoucherCell(
      {Key key,
      @required this.voucher,
      @required this.mode,
      @required this.mainButtonTapped,
      this.secondaryButtonTapped})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VoucherCellState();
  }
}

double tapPositionX;
double tapPositionY;

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
                          return Row(
                            children: <Widget>[
                              Text(
                                  snap.hasData
                                      ? snap.data.toUpperCase()
                                      : "Error",
                                  style: FontHelper.bold(Colors.black, 12.0)),
                              GestureDetector(
                                  onTapDown: (details) {
                                    tapPositionX = details.globalPosition.dx;
                                    tapPositionY = details.globalPosition.dy;
                                  },
                                  onTap: () {
                                    showInfomationDialog(
                                        x: tapPositionX,
                                        y: tapPositionY,
                                        context: context,
                                        subTitle:
                                            "A Discount Voucher from Dabao entitles you to a promotion that reduces your overall cost of ordering a meal through the Dabao. For one use only per voucher.",
                                        title: "What is a Discount Voucher?");
                                  },
                                  child: Container(
                                      color: Colors.transparent,
                                      padding: EdgeInsets.fromLTRB(
                                          10.0, 0.0, 5.0, 0.0),
                                      child: Image.asset(
                                          'assets/icons/question_mark.png')))
                            ],
                          );
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
                                  ? "Valid Until " +
                                      DateTimeHelper.convertDateTimeToDate(
                                          snap.data)
                                  : "",
                              style: FontHelper.bold(Colors.black, 10.0));
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 7.0, right: 7.0),
                        child: widget.mode == VoucherCellMode.redeem
                            ? Row(children: <Widget>[
                                Expanded(
                                  child: RaisedButton(
                                    padding: EdgeInsets.all(0),
                                    elevation: 3.0,
                                    highlightElevation: 0.0,
                                    color: ColorHelper.dabaoOrange,
                                    child: Text(
                                      'Redeem',
                                      textAlign: TextAlign.center,
                                      style:
                                          FontHelper.bold(Colors.white, 12.0),
                                    ),
                                    onPressed: () {
                                      widget.mainButtonTapped(widget.voucher);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                )
                              ])
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  StreamBuilder(
                                    stream: widget.voucher.status,
                                    builder: (context, snap) {
                                      if (snap.data == null) return Offstage();

                                      if (snap.data == voucher_Status_Open)
                                        return Expanded(
                                          child: RaisedButton(
                                            padding: EdgeInsets.all(0),
                                            elevation: 3.0,
                                            highlightElevation: 0.0,
                                            color: ColorHelper.dabaoOrange,
                                            child: Text(
                                              'Apply Now',
                                              textAlign: TextAlign.center,
                                              style: FontHelper.bold(
                                                  Colors.white, 12.0),
                                            ),
                                            onPressed: () {
                                              widget.mainButtonTapped(
                                                  widget.voucher);
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                          ),
                                        );

                                      if (snap.data == voucher_Status_InUsed)
                                        return Expanded(
                                          child: RaisedButton(
                                            padding: EdgeInsets.all(0),
                                            elevation: 0.0,
                                            highlightElevation: 0.0,
                                            color: ColorHelper.dabaoOffGreyD0,
                                            child: Text(
                                              'Applied',
                                              textAlign: TextAlign.center,
                                              style: FontHelper.bold(
                                                  Colors.black, 12.0),
                                            ),
                                            onPressed: () {},
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                          ),
                                        );
                                    },
                                  )
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
