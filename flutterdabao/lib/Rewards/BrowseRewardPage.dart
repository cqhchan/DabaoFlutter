import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/DabaoerReward.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Rewards/MilestoneList.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:rxdart/rxdart.dart';

class BrowseRewardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BrowseRewardPageState();
  }
}

class _BrowseRewardPageState extends State<BrowseRewardPage>
    with AutomaticKeepAliveClientMixin {
  final MutableProperty<User> currentUser =
      ConfigHelper.instance.currentUserProperty;

  final MutableProperty<DabaoerReward> dabaoerMilestones =
      ConfigHelper.instance.currentDabaoerRewards;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              height: 50.0,
              decoration: BoxDecoration(
                color: Color(0xFF353A50),
                borderRadius: BorderRadius.circular(13),
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BubbleTabIndicator(
                    insets: EdgeInsets.all(0),
                    indicatorRadius: 13,
                    indicatorHeight: constraints.maxHeight,
                    indicatorColor: Color(0xFF3ACCE1),
                    tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  ),
                  labelStyle: FontHelper.normal2TextStyle,
                  labelColor: ColorHelper.dabaoOffWhiteF5,
                  unselectedLabelColor: ColorHelper.dabaoOffGrey70,
                  tabs: [
                    Tab(
                      child: Text(
                        "DABAOEE",
                        style: FontHelper.semiBold(null, 12.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "DABAOER",
                        style: FontHelper.semiBold(null, 12.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  MilestonesList(
                    milestones:
                        Observable(dabaoerMilestones.producer.switchMap((data) {
                      if (data != null) return data.milestones;
                      return null;
                    })),
                    points: Observable(currentUser.producer.switchMap((user) {
                      if (user == null) return Observable.just(null);
                      return Observable(user.currentDabaoerRewardsNumber);
                    })),
                  ),
                  MilestonesList(
                    milestones:
                        Observable(dabaoerMilestones.producer.switchMap((data) {
                      if (data != null) return data.milestones;
                      return null;
                    })),
                    points: Observable(currentUser.producer.switchMap((user) {
                      if (user == null) return Observable.just(null);
                      return Observable(user.currentDabaoerRewardsNumber);
                    })),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
