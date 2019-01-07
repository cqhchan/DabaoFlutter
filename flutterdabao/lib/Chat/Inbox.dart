import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/Conversation.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutterdabao/Model/Message.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';

// TODO fix a bug where by if a image is error, it causes the card to not load properly
class ChatPage extends StatefulWidget {
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  MutableProperty<List<Channel>> currentUserChannels;

  String otherUser;

  @override
  void initState() {
    super.initState();

    currentUserChannels = ConfigHelper.instance.currentUserChannelProperty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Your Inbox', style: FontHelper.header3TextStyle),
      ),
      body: _buildChatPage(),
    );
  }

  Widget _buildChatPage() {
    return StreamBuilder<List<Channel>>(
      stream: currentUserChannels.producer.map((channels) {
        List<Channel> temp = List.from(channels);

        temp.removeWhere((channel) => channel.lastSent.value == null);

        temp.sort(
            (lhs, rhs) => rhs.lastSent.value.compareTo(lhs.lastSent.value));

        return temp;
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Offstage();
        if (snapshot.hasData) return _buildChatList(context, snapshot.data);
      },
    );
  }

  ListView _buildChatList(BuildContext context, List<Channel> snapshot) {
    return ListView(
      // key: new Key(randomString(20)),

      cacheExtent: 500.0 * snapshot.length,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      children: snapshot.map((data) => _ChannelCell(channel: data)).toList(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ChannelCell extends StatefulWidget {
  final Channel channel;

  _ChannelCell({Key key, this.channel}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChannelCellState();
  }
}

class _ChannelCellState extends State<_ChannelCell> {
  Channel channel;
  @override
  void initState() {
    super.initState();
    channel = widget.channel;
  }

  @override
  Widget build(BuildContext context) {
    return _buildChat(context, channel);
  }

  @override
  void didUpdateWidget(_ChannelCell oldWidget) {
    if (channel != widget.channel) {
      setState(() {
        channel = widget.channel;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildChat(BuildContext context, Channel channel) {
    return StreamBuilder<User>(
      stream: Observable.combineLatest2<List<String>, User, User>(
          channel.participantsID,
          ConfigHelper.instance.currentUserProperty.producer,
          (participantsID, currentUser) {
        List tempID = List.from(participantsID);
        if (tempID == null || currentUser == null) {
          return null;
        }
        tempID.remove(currentUser.uid);

        if (tempID.length == 0) {
          return null;
        }

        return User.fromUID(tempID.first);
      }),
      builder: (context, snap) => (!snap.hasData || snap.data == null)
          ? Offstage()
          : Column(
              children: <Widget>[
                ListTile(
                  isThreeLine: true,
                  contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  leading: StreamBuilder<String>(
                      stream: snap.data.thumbnailImage,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null)
                          return FittedBox(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Image.asset(
                                    'assets/icons/profile_icon.png',
                                    fit: BoxFit.fill,
                                  )),
                            ),
                          );
                        else
                          return FittedBox(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data,
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
                          );
                      }),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StreamBuilder<String>(
                          stream: snap.data.name,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null)
                              return Offstage();
                            return Text(
                              snapshot.data != null ? snapshot.data : '',
                              style: FontHelper.regular10Black,
                            );
                          }),
                      StreamBuilder<Order>(
                          stream: channel.orderUid.map((orderID) =>
                              orderID == null ? null : Order.fromUID(orderID)),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null)
                              return Offstage();

                            return StreamBuilder<String>(
                              stream: snapshot.data.foodTag,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (!snapshot.hasData) return Offstage();

                                return Text(
                                  snapshot.data != null
                                      ? StringHelper.upperCaseWords(
                                          snapshot.data)
                                      : 'Order Deleted',
                                  style: FontHelper.semiBold16Black,
                                );
                              },
                            );
                          }),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 100, 0),
                    child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('channels')
                            .document(channel.orderUid.value +
                                channel.deliverer.value)
                            .collection('messages')
                            .orderBy(Message.timestampKey, descending: true)
                            .limit(1)
                            .snapshots()
                            .map((snapshot) => snapshot.documents.last),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Offstage();
                          return Text(
                            snapshot.data['M'] != null &&
                                    snapshot.data['M'] != ''
                                ? snapshot.data['M']
                                : '[Photo]',
                            style: FontHelper.regular12Black,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                  ),
                  trailing: Column(
                    children: <Widget>[
                      StreamBuilder<DateTime>(
                        stream: channel.lastSent,
                        builder: (BuildContext context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null)
                            return Offstage();
                          return Text(
                            DateTimeHelper.convertTimeToDisplayString(
                                snapshot.data),
                            style: FontHelper.semiBold10Grey,
                          );
                        },
                      ),
                      //Building unread messages
                      Container(
                        height: 50,
                        width: 50,
                        child: StreamBuilder<int>(
                          stream: channel.unreadMessages,
                          builder: (BuildContext context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data == null ||
                                snapshot.data == 0) return Offstage();

                            return Center(
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorHelper.dabaoOrange),
                                child: Center(
                                    child: Text(
                                  snapshot.data >= 100
                                      ? "99"
                                      : snapshot.data.toString(),
                                  style: FontHelper.medium(Colors.white, 12.0),
                                )),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    _toChat(channel);
                  },
                ),
                Divider(
                  height: 0,
                )
              ],
            ),
    );
  }

  _toChat(Channel channel) {
    GlobalKey<ConversationState> key =
        GlobalKey<ConversationState>(debugLabel: channel.uid);
    //TODO
    //For some reason, you need to rebuild the channel....?
    Channel newChannel = Channel.fromUID(channel.uid);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Conversation(
              channel: newChannel,
              key: key,
            ),
      ),
    );
  }
}
