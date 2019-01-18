import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/DabaoeeReward.dart';
import 'package:flutterdabao/Model/DabaoerReward.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:percent_indicator/percent_indicator.dart';

enum MilestoneMode { Locked, InProgress, Completed }

class MilestonesList extends StatefulWidget {
  final Observable<List> milestones;
  final Observable<int> points;
  final context;
  MilestonesList({
    Key key,
    this.context,
    this.milestones,
    this.points,
  }) : super(key: key);
  _MilestonesListState createState() => _MilestonesListState();
}

class _MilestonesListState extends State<MilestonesList>
    with AutomaticKeepAliveClientMixin, HavingSubscriptionMixin {
  MutableProperty<int> numberOfCompletedOrders = MutableProperty(0);

  void initState() {
    super.initState();


    subscription.add(numberOfCompletedOrders.bindTo(widget.points));


  }

  @override
    void dispose() {
      disposeAndReset();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          //Retriving the total reward number
          Expanded(child: Offstage(offstage: false, child: _buildMileStones())),
        ],
      ),
    );
  }

  Widget _buildMileStones() {
    return StreamBuilder<List>(
        stream: widget.milestones,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Offstage();

          List temp = snapshot.data;

          temp.sort((lhs, rhs) => lhs.quantityOfComfirmedOrders.value
              .compareTo(rhs.quantityOfComfirmedOrders.value));

          return ListView.builder(
            shrinkWrap: true,
            itemCount: temp.length,
            itemBuilder: (BuildContext context, int index) {
              var previousItem;
              if (index == 0) {
              } else {
                previousItem = temp[index - 1];
              }
              var item = temp[index];
              return _buildItemCell(item, previousItem);
            },
          );
        });
  }

  Widget _buildItemCell(item, previousItem) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.fromLTRB(18, 5, 18, 5),
      color: Colors.white,
      elevation: 6.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 150),
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(padding: EdgeInsets.only(top: 12), child: _buildTitleDescription(item)),
                  ),
                  _buildBadges(item, previousItem),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                              child: Column(
                  children: <Widget>[
                    _buildProgress(item, previousItem),
                    _buildFooter(item)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleDescription(data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StreamBuilder(
          stream: data.title,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Offstage();
            return Text(
              snapshot.data,
              style: FontHelper.semiBold16Black,
            );
          },
        ),
        SizedBox(
          height: 10,
        ),
        StreamBuilder(
          stream: data.description,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Offstage();
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                snapshot.data,
                style: FontHelper.semiBold12Black,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBadges(item, previousItem) {
    return StreamBuilder<MilestoneMode>(
        stream: Observable.combineLatest3<int, int, int, MilestoneMode>(
            item.quantityOfComfirmedOrders,
            previousItem == null
                ? BehaviorSubject(seedValue: 0)
                : previousItem.quantityOfComfirmedOrders,
            numberOfCompletedOrders.producer,
            (currentQty, previousQty, completed) {
          if (completed >= currentQty) return MilestoneMode.Completed;
          if (completed < previousQty) return MilestoneMode.Locked;

          return MilestoneMode.InProgress;
        }),
        builder: (context, snapshot) {
          if (snapshot.data == null) return Offstage();

          switch (snapshot.data) {
            case MilestoneMode.Completed:
              return Container(
                  height: 76,
                  width: 76,
                  child: Center(
                      child: Image.asset('assets/icons/CompletedIcon.png')));

            case MilestoneMode.Locked:
              return Container(
                  height: 76,
                  width: 76,
                  child: Center(
                      child: Image.asset('assets/icons/LockedIcon.png')));

            case MilestoneMode.InProgress:
              return Container(
                  height: 76,
                  width: 76,
                  child: Center(
                      child: Image.asset('assets/icons/InProgressIcon.png')));
          }
        });
  }

  Widget _buildProgress(item, previousItem) {
    return StreamBuilder<MilestoneMode>(
        stream: Observable.combineLatest3<int, int, int, MilestoneMode>(
            item.quantityOfComfirmedOrders,
            previousItem == null
                ? BehaviorSubject(seedValue: 0)
                : previousItem.quantityOfComfirmedOrders,
            numberOfCompletedOrders.producer,
            (currentQty, previousQty, completed) {
          if (completed >= currentQty) return MilestoneMode.Completed;
          if (completed < previousQty) return MilestoneMode.Locked;

          return MilestoneMode.InProgress;
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Offstage();
          if (numberOfCompletedOrders.value == null) return Offstage();

          int max = item.quantityOfComfirmedOrders.value -
              (previousItem == null
                  ? 0
                  : previousItem.quantityOfComfirmedOrders.value);

          switch (snapshot.data) {
            case MilestoneMode.Completed:
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 0, bottom: 5),
                    child: Text(
                      "Completed: ${max}/${max}",
                      style: FontHelper.semiBold(ColorHelper.dabaoOrange, 12.0),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraint) {
                      return LinearPercentIndicator(
                        padding: EdgeInsets.all(0),
                        progressColor: ColorHelper.dabaoOrange,
                        width: constraint.maxWidth,
                        percent: 1.0,
                      );
                    },
                  ),
                ],
              );

            case MilestoneMode.InProgress:
              return StreamBuilder<int>(
                stream: numberOfCompletedOrders.producer,
                builder: (context, snap) {

                  int currentNumber = snap.data == null ? 0 : snap.data -
                      (previousItem == null
                          ? 0
                          : previousItem.quantityOfComfirmedOrders.value);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 0, bottom: 5),
                        child: Text(
                          "In Progress: ${currentNumber}/${max}",
                          style: FontHelper.semiBold(Colors.black, 12.0),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraint) {
                          return LinearPercentIndicator(
                            padding: EdgeInsets.all(0),
                            progressColor: ColorHelper.dabaoYellow,
                            width: constraint.maxWidth,
                            percent:
                                math.min(1.0, math.max(0, (currentNumber + 0.0) / (max + 0.0))),
                          );
                        },
                      ),
                    ],
                  );
                },
              );

            case MilestoneMode.Locked:
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 0, bottom: 5),
                    child: Text(
                      "Locked: 0/${max}",
                      style: FontHelper.semiBold(
                          ColorHelper.dabaoOffBlack9B, 12.0),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraint) {
                      return LinearPercentIndicator(
                        padding: EdgeInsets.all(0),
                        progressColor: ColorHelper.dabaoOffGreyD0,
                        width: constraint.maxWidth,
                        percent: 0.0,
                      );
                    },
                  ),
                ],
              );
              break;
          }
        });
  }

  Widget _buildFooter(data) {
    if (data is DabaoerRewardsMilestone) {
      return StreamBuilder<double>(
        stream: data.rewardAmount,
        builder: (context, snapshot) {
          return Text(
            'Reward: ${StringHelper.doubleToPriceString(snapshot.data)}',
            style: FontHelper.semiBold10Grey,
          );
        },
      );
    } else if (data is DabaoeeRewardsMilestone) {
      return StreamBuilder(
        stream: data.voucherDescription,
        builder: (context, snapshot) {
          return Text(
            'Reward: ${snapshot.data}',
            style: FontHelper.semiBold10Grey,
          );
        },
      );
    }
    return Text('');
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
