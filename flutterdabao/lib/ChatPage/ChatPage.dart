import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/ChatPage/DabaoeeChat.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/Channels.dart';

class ChatPage extends StatefulWidget {
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Inbox', style: FontHelper.header3TextStyle),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
          return _buildList(context, snapshot.data.documents);
      },
    );
  }

  ListView _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    String deliverer;

    final channel = Channel.fromDocument(data);
    //check for deliverer
    final List<String> participants = channel.participantsID.value;
    participants.forEach((result) {
      if (result != ConfigHelper.instance.currentUserProperty.value.uid) {
        deliverer = result;
      }
    });

    if (channel.lastSent.value == null) {
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
                  .document(deliverer)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Offstage();
                if (snapshot.hasData) {
                  return CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data['tn']),
                    radius: 20,
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
                            .document(deliverer)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Offstage();
                          return Text(
                            snapshot.data['name'],
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
                        snapshot.data['FT'],
                        style: FontHelper.semiBold16Black,
                      );
                    }),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 100, 0),
              child: Text(
                channel.lastMessage.value != null
                    ? channel.lastMessage.value
                    : '[Photo]',
                style: FontHelper.regular12Black,
              ),
            ),
            onTap: () {
              _toChat(channel.orderUid.value, deliverer);
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
    Channel channel = Channel.fromUID(
        orderUid + ConfigHelper.instance.currentUserProperty.value.uid);
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
                deliverer: deliverer,
              ),
        ),
      );
    });
  }
}
