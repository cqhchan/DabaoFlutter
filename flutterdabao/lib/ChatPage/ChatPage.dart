import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/ChatPage/DabaoeeChat.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progress_indicators/progress_indicators.dart';

class ChatPage extends StatefulWidget {
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  String otherUser;

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
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('channels')
          .where('P',
              arrayContains:
                  ConfigHelper.instance.currentUserProperty.value.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Offstage();
        if (snapshot.hasData)
          return _buildChatList(context, snapshot.data.documents);
      },
    );
  }

  ListView _buildChatList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      cacheExtent: 500.0 * snapshot.length,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      children: snapshot.map((data) => _buildChat(context, data)).toList(),
    );
  }

  Widget _buildChat(BuildContext context, DocumentSnapshot data) {
    final channel = Channel.fromDocument(data);
    //check for deliverer in the list of participants
    final List<String> participants = channel.participantsID.value;
    participants.forEach((result) {
      if (result != ConfigHelper.instance.currentUserProperty.value.uid) {
        return otherUser = result;
      }
    });
    print('deliverer: $otherUser');

    //the user cannot converse with himself
    if (channel.lastSent.value == null || otherUser == null) {
      return Offstage();
    } else {
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
                    return CircleAvatar(
                      child: Icon(Icons.camera_alt),
                      radius: 20,
                    );
                  return FittedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
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
                            snapshot.data['N'] != null
                                ? snapshot.data['N']
                                : '',
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
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Offstage();
                      return Text(
                        snapshot.data['FT'] != null ? snapshot.data['FT'] : '',
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
                      .document(
                          channel.orderUid.value + channel.deliverer.value)
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
              _toChat(channel.orderUid.value, channel.deliverer.value);
            },
          ),
          Divider(
            height: 0,
          )
        ],
      );
    }
  }

  _toChat(String orderUid, String deliverer) {
    Channel channel = Channel.fromUID(orderUid + deliverer);
    Firestore.instance
        .collection("channels")
        .document(channel.uid)
        .get()
        .then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Conversation(
                channel: channel,
                otherUser: otherUser,
              ),
        ),
      );
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
