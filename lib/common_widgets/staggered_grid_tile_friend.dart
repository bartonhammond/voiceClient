import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:voiceClient/app/sign_in/friend_button.dart';
import 'package:voiceClient/constants/transparent_image.dart';

class StaggeredGridTileFriend extends StatelessWidget {
  const StaggeredGridTileFriend({
    @required this.onPush,
    @required this.friend,
    @required this.friendButton,
  });
  final ValueChanged<Map<String, dynamic>> onPush;
  final Map friend;
  final FriendButton friendButton;

  @override
  Widget build(BuildContext context) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    double _fontSize = 16;
    switch (deviceType) {
      case DeviceScreenType.watch:
        _fontSize = 10;
        break;
      default:
        _fontSize = 16;
    }
    return Card(
      child: Column(
        children: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {
                onPush(<String, dynamic>{
                  'id': friend['id'],
                });
              },
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: friend['image'],
              ),
            ),
          ),
          Text(
            friend['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize),
          ),
          Text(
            friend['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize),
          ),
          Text(
            friend['birth'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: _fontSize),
          ),
          friendButton
        ],
      ),
    );
  }
}
