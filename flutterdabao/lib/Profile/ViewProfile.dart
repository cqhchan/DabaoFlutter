import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/Rating.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/ViewOrders/ViewOrderPage.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewProfile extends StatefulWidget {
  final AsyncSnapshot<User> currentUser;

  const ViewProfile({Key key, this.currentUser}) : super(key: key);
  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildUser(),
              ],
            ),
            _buildRatingCard(),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUser() {
    return Column(
      children: <Widget>[
        StreamBuilder<String>(
            stream: widget.currentUser.data.thumbnailImage,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null)
                return FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(
                          'assets/icons/profile_icon.png',
                          fit: BoxFit.fill,
                        )),
                  ),
                );
              else
                return Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: <Widget>[
                    FittedBox(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data,
                            placeholder: GlowingProgressIndicator(
                              child: Icon(
                                Icons.image,
                                size: 100,
                              ),
                            ),
                            errorWidget: Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
            }),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<String>(
                  stream: widget.currentUser.data.name,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Offstage();
                    return Text(
                      snapshot.data != null ? snapshot.data : '',
                      style: FontHelper.semiBold20Black,
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<String>(
                stream: widget.currentUser.data.handPhone,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Offstage();
                  return GestureDetector(
                      onTap: (){makePhoneCall('tel:'+snapshot.data);},
                      child: Icon(
                        Icons.phone,
                        color: Colors.black,
                      ));
                },
              ),
            )
          ],
        ),
      ],
    );
  }

  

  Widget _buildRatingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.all(11.0),
      color: Colors.white,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<int>(
                  stream: widget.currentUser.data.completedOrders,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Column(
                        children: <Widget>[
                          Text(
                            "0",
                            style: FontHelper.semiBold20Black,
                          ),
                          Text(
                            'Completed\nOrders',
                            style: FontHelper.regular11Black,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    print('Completed Orders: ${snapshot.data.toString()}');
                    return Column(
                      children: <Widget>[
                        Text(
                          snapshot.data.toString(),
                          style: FontHelper.semiBold20Black,
                        ),
                        Text(
                          'Completed\nOrders',
                          style: FontHelper.regular11Black,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
            ),
            Container(
              height: 60,
              width: 1.0,
              color: Color(0x11000000),
            ),
            Expanded(
              child: StreamBuilder<int>(
                  stream: widget.currentUser.data.completedDeliveries,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Column(
                        children: <Widget>[
                          Text(
                            "0",
                            style: FontHelper.semiBold20Black,
                          ),
                          Text(
                            'Completed\DDeliveries',
                            style: FontHelper.regular11Black,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    print('Completed Deliveries: ${snapshot.data.toString()}');
                    return Column(
                      children: <Widget>[
                        Text(
                          snapshot.data.toString(),
                          style: FontHelper.semiBold20Black,
                        ),
                        Text(
                          'Completed\nDeliveries',
                          style: FontHelper.regular11Black,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
            ),
            Container(
              height: 60,
              width: 1.0,
              color: Color(0x11000000),
            ),
            Expanded(
              child: StreamBuilder<double>(
                  stream: widget.currentUser.data.rating,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null)
                      return Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "0",
                                style: FontHelper.semiBold20Black,
                              ),
                              Image.asset('assets/icons/yellow_star.png')
                            ],
                          ),
                          Text(
                            'Rating',
                            style: FontHelper.regular11Black,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    print('Rating: ${snapshot.data.toString()}');
                    return Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              snapshot.data.toString(),
                              style: FontHelper.semiBold20Black,
                            ),
                            Image.asset('assets/icons/yellow_star.png')
                          ],
                        ),
                        Text(
                          'Rating',
                          style: FontHelper.regular11Black,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return Expanded(
      child: StreamBuilder<List<Rating>>(
          stream: widget.currentUser.data.listOfReviews
              .switchMap((list) => list == null ? null : Observable.just(list)),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null)
              return Center(child: Text('Please Check Your Connection'));
            if (snapshot.hasData) {
              return _buildList(snapshot.data);
            }
          }),
    );
  }

  Widget _buildList(List<Rating> reviews) {
    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      children: reviews.map((data) => _buildRatingCell(data)).toList(),
    );
  }

  Widget _buildRatingCell(Rating data) {
    return StreamBuilder<User>(
      stream: data.reviewer
          .where((uid) => uid != null)
          .map((uid) => uid == null ? null : User.fromUID(uid)),
      builder: (context, user) {
        if (!user.hasData || user.data == null) {
          return Offstage();
        } else if (user.hasData)
          return Column(
            children: <Widget>[
              ListTile(
                leading: FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: user.data.thumbnailImage.value == null
                          ? Image.asset(
                              'assets/icons/profile_icon.png',
                              fit: BoxFit.fill,
                            )
                          : CachedNetworkImage(
                              imageUrl: user.data.thumbnailImage.value,
                              placeholder: GlowingProgressIndicator(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                ),
                              ),
                              errorWidget: Icon(Icons.error),
                            ),
                    ),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.data.name.value != null ? user.data.name.value : '',
                      style: FontHelper.regular14Black,
                    ),
                    Text(
                      DateTimeHelper.convertDateTimeToAgo(
                          data.createdDate.value),
                      style: FontHelper.semiBold11Grey,
                    ),
                  ],
                ),
                subtitle: Text(
                  data.message.value,
                  style: FontHelper.regular12Black,
                ),
                trailing: SmoothStarRating(
                  allowHalfRating: false,
                  starCount: 5,
                  rating: data.rating.value,
                  size: 15.0,
                  color: ColorHelper.dabaoOrange,
                  borderColor: ColorHelper.dabaoOrange,
                ),
              ),
              Divider(
                height: 0,
              )
            ],
          );
      },
    );
  }
}
