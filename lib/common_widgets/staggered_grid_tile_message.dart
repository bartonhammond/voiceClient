import 'package:flutter/material.dart';
import 'package:voiceClient/app/sign_in/friend_button.dart';
import 'package:voiceClient/constants/transparent_image.dart';

class StaggeredGridTileMessage extends StatelessWidget {
  const StaggeredGridTileMessage({
    @required this.onPush,
    @required this.message,
    @required this.approveFriendButton,
    @required this.rejectFriendButton,
  });
  final ValueChanged<String> onPush;
  final Map<String, dynamic> message;
  final FriendButton approveFriendButton;
  final FriendButton rejectFriendButton;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Center(
              child: Text(
                'Friend Request',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: message['User']['image'],
                  height: 50,
                ),
              ),
            ),
            Text(
              message['User']['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
            Text(
              message['User']['home'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
            ),
            Text(
              message['User']['birth'].toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
            ),
            ButtonBar(mainAxisSize: MainAxisSize.min, children: <Widget>[
              approveFriendButton,
              rejectFriendButton,
            ])
          ],
        ),
      ),
    );
  }
}
