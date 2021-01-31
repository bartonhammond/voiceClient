import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';

class FriendMessagePage extends StatefulWidget {
  const FriendMessagePage({
    this.user,
  });
  final Map<String, dynamic> user;
  @override
  FriendMessagePageState createState() => FriendMessagePageState();
}

class FriendMessagePageState extends State<FriendMessagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Strings.messagesPageMessage.i18n),
        ),
        body: Padding(
          child: ListView(
            children: <Widget>[
              FriendWidget(user: widget.user),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ));
  }
}
