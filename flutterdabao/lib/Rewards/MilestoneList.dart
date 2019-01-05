import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/DabaoerReward.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MilestonesList extends StatefulWidget {
  final Stream<List<DabaoerRewardsMilestone>> milestones;
  final Stream<int> points;
  final context;
  MilestonesList({
    Key key,
    this.context,
    this.milestones,
    this.points,
  }) : super(key: key);
  _MilestonesListState createState() => _MilestonesListState();
}

class _MilestonesListState extends State<MilestonesList> {
  int _totalPoints;
  int temp;
  int lastTemp;
  bool flag;

  void initState() {
    super.initState();
    _totalPoints = 0;
    temp = 0;
    lastTemp = 0;
    flag = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          //Retriving the total reward number
          Offstage(
              offstage: false,
              child: StreamBuilder<int>(
                stream: widget.points,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Offstage();
                  return _buildMileStones(snapshot.data);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildMileStones(data) {
    return StreamBuilder<List<DabaoerRewardsMilestone>>(
        stream: Observable(widget.milestones),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return JumpingDotsProgressIndicator();
          _totalPoints = data;
          return ListView(
            shrinkWrap: true,
            children: snapshot.data
                .map((_milestone) => _buildItemCell(
                      _milestone,
                    ))
                .toList(),
          );
        });
  }

  Widget _buildItemCell(DabaoerRewardsMilestone data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.fromLTRB(18, 5, 18, 5),
      color: Colors.white,
      elevation: 6.0,
      child: Container(
        height: 110,
        margin: EdgeInsets.fromLTRB(10, 16, 10, 10),
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                  child: _buildTitleDescription(data),
                ),
                _buildBadges(),
              ],
            ),
            Column(
              children: <Widget>[_buildProgress(data), _buildFooter()],
            ),
          ],
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

  Widget _buildBadges() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.asset('assets/icons/shield.png'),
        Align(
            child: Text(
          '10',
          style: FontHelper.semiBold12Black,
        ))
      ],
    );
  }

  Widget _buildProgress(data) {
    return StreamBuilder<int>(
      stream: data.quantityOfComfirmedOrders,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Offstage();

        temp = _totalPoints;

        if (_totalPoints >= snapshot.data) {
          _totalPoints = _totalPoints - snapshot.data;
          return Column(
            children: <Widget>[
              Text(
                "Progress: ${snapshot.data.toString()}/${snapshot.data.toString()}",
                style: FontHelper.semiBold12Grey,
              ),
              LayoutBuilder(
                builder: (context, constraint) {
                  return LinearPercentIndicator(
                    progressColor: Color(0xFFF5A510),
                    width: constraint.maxWidth,
                    percent: 1.0,
                  );
                },
              ),
            ],
          );
        }

        if (_totalPoints <= 0) {
          return Column(
            children: <Widget>[
              Text(
                "Progress: 0/${snapshot.data.toString()}",
                style: FontHelper.semiBold12Grey,
              ),
              LayoutBuilder(
                builder: (context, constraint) {
                  return LinearPercentIndicator(
                    progressColor: Color(0xFFF5A510),
                    width: constraint.maxWidth,
                    percent: 0.0,
                  );
                },
              ),
            ],
          );
        }

        if (_totalPoints > 0) {
          _totalPoints = _totalPoints - snapshot.data;
          return Column(
            children: <Widget>[
              Text(
                "Progress: ${temp.toString()}/${snapshot.data.toString()}",
                style: FontHelper.semiBold12Grey,
              ),
              LayoutBuilder(
                builder: (context, constraint) {
                  return LinearPercentIndicator(
                    progressColor: Color(0xFFF5A510),
                    width: constraint.maxWidth,
                    percent: (_totalPoints + snapshot.data) / snapshot.data,
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildFooter() {
    return Text(
      'Reward:',
      style: FontHelper.semiBold10Grey,
    );
  }
}
