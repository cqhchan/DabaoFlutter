import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Model/Voucher.dart';
import 'package:flutterdabao/Rewards/VoucherCell.dart';

class SearchPromoCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchPromoCodePageState();
  }
}

class _SearchPromoCodePageState extends State<SearchPromoCodePage> {
  bool _loading = false;
  List<Voucher> _results;
  TextEditingController _controller = TextEditingController();
  String _code = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      setState(() {
        _code = _controller.value.text;
      });
    });
  }

  Timer _resultsTimer;
  Future _getResultsDebounced() async {
    if (_results == null || _results.length == 0) {
      setState(() {
        _loading = true;
      });
    }

    if (_resultsTimer != null && _resultsTimer.isActive) {
      _resultsTimer.cancel();
    }

    _resultsTimer = new Timer(new Duration(milliseconds: 400), () async {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = true;
      });

      var results = await FirebaseCollectionReactiveOnce<Voucher>(Firestore
              .instance
              .collection("vouchers")
              .where(Voucher.statusKey, isEqualTo: voucher_Status_Public)
              .where(Voucher.codeKey, isEqualTo: _code.toUpperCase()))
          .future;

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _results = results;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
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
          backgroundColor: ColorHelper.dabaoOffWhiteF5,
          title: new TextField(
            textCapitalization: TextCapitalization.characters,
            controller: _controller,
            autofocus: true,
            decoration:
                new InputDecoration.collapsed(hintText: "Enter promo code"),
            style: Theme.of(context).textTheme.title,
            onSubmitted: (String value) {
              setState(() {
                _code = _controller.text;
              });
              _getResultsDebounced();
            },
          ),
          actions: _code.length == 0
              ? []
              : [
                  new IconButton(
                      icon: new Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _controller.text = _code = '';
                        });
                      }),
                ],
        ),
        body: _loading
            ? new Center(
                child: new Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: new CircularProgressIndicator()),
              )
            : _results == null
                ? Container()
                : _results.length == 0
                    ? new Center(
                        child: new Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text("No Voucher Found, try another promo Code"),
                      ))
                    : new ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, count) {
                          return VoucherCell(
                            voucher: _results[count],
                            mode: VoucherCellMode.redeem,
                            mainButtonTapped: (voucher) async {
                              showLoadingOverlay(context: context);

                              await FirebaseCloudFunctions.redeemVoucher(
                                      userID: ConfigHelper.instance
                                          .currentUserProperty.value.uid,
                                      voucherID: voucher.uid)
                                  .then((success) {
                                if (success) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pop();
                                  final snackBar = SnackBar(
                                      content: Text(
                                          'An Error has occured. Please check your network connectivity'));
                                  Scaffold.of(context).showSnackBar(snackBar);
                                }
                              }).catchError((error) {
                                if (error is PlatformException) {
                                  PlatformException e = error;
                                  Navigator.of(context).pop();
                                  final snackBar =
                                      SnackBar(content: Text(e.message));
                                  Scaffold.of(context).showSnackBar(snackBar);
                                } else {
                                  Navigator.of(context).pop();
                                  final snackBar = SnackBar(
                                      content: Text(
                                          'An Error has occured. Please check your network connectivity'));
                                  Scaffold.of(context).showSnackBar(snackBar);
                                }
                              });
                            },
                          );
                        }));
  }
}
