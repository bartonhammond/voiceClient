import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:flutter/material.dart';

class StaggeredGridTileFriend extends StatelessWidget {
  const StaggeredGridTileFriend({
    @required this.onPush,
    @required this.friend,
    @required this.friendButton,
  });
  final ValueChanged<Map<String, dynamic>> onPush;
  final Map friend;
  final Widget friendButton;

  @override
  Widget build(BuildContext context) {
    return FriendWidget(
      user: friend,
      friendButton: friendButton,
      onFriendPush: onPush,
    );
  }
}
