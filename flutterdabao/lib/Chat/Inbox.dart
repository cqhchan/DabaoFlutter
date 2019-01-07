import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/DabaoeeChat.dart';
import 'package:flutterdabao/Firebase/FirebaseCollectionReactive.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rxdart/rxdart.dart';

class ChatPage extends StatefulWidget {
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  Observable<List<Channel>> _listOfChannelsRef;

  String otherUser;

  @override
  void initState() {
    super.initState();

    _listOfChannelsRef = FirebaseCollectionReactive<Channel>(Firestore.instance
            .collection('channels')
            .where('P',
                arrayContains:
                    ConfigHelper.instance.currentUserProperty.value.uid))
        .observable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Inbox', style: FontHelper.header3TextStyle),
      ),
      body: _buildChatPage(),
    );
  }

  Widget _buildChatPage() {
    return StreamBuilder<List<Channel>>(
      stream: _listOfChannelsRef,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Offstage();
        if (snapshot.hasData) return _buildChatList(context, snapshot.data);
      },
    );
  }

  ListView _buildChatList(BuildContext context, List<Channel> snapshot) {
    return ListView(
      cacheExtent: 500.0 * snapshot.length,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      children: snapshot.map((data) => _buildChat(context, data)).toList(),
    );
  }

  Widget _buildChat(BuildContext context, Channel channel) {
    final List<String> participants = channel.participantsID.value;
    for (int i = 0; i < participants.length; i++) {
      if (participants[i] !=
          ConfigHelper.instance.currentUserProperty.value.uid) {
        otherUser = participants[i];
      }
    }
    return _buildItemCell(channel, otherUser);
  }

  Widget _buildItemCell(Channel channel, String otherUser) {
    if (channel.lastSent.value == null) {
      return Offstage();
    }
    return Column(
      children: <Widget>[
        ListTile(
          isThreeLine: true,
          contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          leading: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(otherUser)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Offstage();
              if (snapshot.hasData) {
                if (snapshot.data['TI'] == null || snapshot.data['TI'] == '')
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
                return FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        imageUrl: snapshot.data['TI'],
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
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document(otherUser)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Offstage();
                        return Text(
                          snapshot.data['N'] != null ? snapshot.data['N'] : '',
                          style: FontHelper.regular10Black,
                        );
                      }),
                  Text(
                    DateTimeHelper.convertTimeToDisplayString(
                        channel.lastSent.value),
                    style: FontHelper.semiBold10Grey,
                  )
                ],
              ),
              StreamBuilder(
                  stream: Firestore.instance
                      .collection('orders')
                      .document(channel.orderUid.value)
                      .snapshots()
                      .map((snapshot) => snapshot.data),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Offstage();
                    return Text(
                      snapshot.data['FT'] != null
                          ? StringHelper.upperCaseWords(snapshot.data['FT'])
                          : 'Order Deleted',
                      style: FontHelper.semiBold16Black,
                    );
                  }),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 100, 0),
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection('channels')
                    .document(channel.orderUid.value + channel.deliverer.value)
                    .collection('messages')
                    .snapshots()
                    .map((snapshot) => snapshot.documents.last),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Offstage();
                  return Text(
                    snapshot.data['M'] != null && snapshot.data['M'] != ''
                        ? snapshot.data['M']
                        : '[Photo]',
                    style: FontHelper.regular12Black,
                  );
                }),
          ),
          onTap: () {
            _toChat(channel.orderUid.value, channel.deliverer.value, otherUser);
          },
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }

  _toChat(String _orderUid, String deliverer, String otherUser) {
    print(
        '\n------------------Current User: ${ConfigHelper.instance.currentUserProperty.value.uid}------------------');
    print('\n------------------Deliverer: $deliverer------------------');
    Channel _channel = Channel.fromUID(_orderUid + deliverer);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Conversation(
              channel: _channel,
              otherUser: otherUser,
            ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
