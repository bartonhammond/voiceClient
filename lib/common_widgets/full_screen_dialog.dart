import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:flutter/material.dart';

class FullScreenDialog extends StatefulWidget {
  const FullScreenDialog({
    this.user,
  });
  final Map<String, dynamic> user;
  @override
  FullScreenDialogState createState() => FullScreenDialogState();
}

class FullScreenDialogState extends State<FullScreenDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Message'),
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
