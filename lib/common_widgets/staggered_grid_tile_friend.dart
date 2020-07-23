import 'package:flutter/material.dart';
import 'package:voiceClient/app/sign_in/friend_button.dart';
import 'package:voiceClient/constants/transparent_image.dart';

class StaggeredGridTileFriend extends StatelessWidget {
  const StaggeredGridTileFriend(
      {@required this.onPush, @required this.friend, this.friendButton});
  final ValueChanged<String> onPush;
  final Map friend;
  final FriendButton friendButton;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          //new Center(child: new CircularProgressIndicator()),
          Center(
            child: GestureDetector(
              onTap: () {
                onPush(friend['id']);
              },
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: friend['image'],
              ),
            ),
          ),
          Text(
            friend['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          Text(
            friend['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          Text(
            friend['birth'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          friendButton
        ],
      ),
    );
  }
}
