import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/Message.dart';
import 'package:flutterdabao/Model/User.dart';

class ChatList extends StatefulWidget {
  final MutableProperty<User> user;
  final context;
  ChatList({Key key, this.context, @required this.user}) : super(key: key);
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildBody(widget.context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('channels')
          .where('P', arrayContains: widget.user.value.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        if (snapshot.hasData)
          return _buildList(context, snapshot.data.documents);
      },
    );
  }

  ListView _buildList(context, List<DocumentSnapshot> snapshot) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(context, data) {
    return Center(child: Text(data.toString()));
  }
}
