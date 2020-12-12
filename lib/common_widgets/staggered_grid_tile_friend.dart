import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/constants/TmpObj.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:flutter/material.dart';

class StaggeredGridTileFriend extends StatelessWidget {
  const StaggeredGridTileFriend({
    @required this.onPush,
    @required this.friend,
    @required this.friendButton,
    @required this.typeUser,
  });
  final ValueChanged<Map<String, dynamic>> onPush;
  final Map friend;
  final TmpObj friendButton;
  final TypeUser typeUser;

  @override
  Widget build(BuildContext context) {
    return FriendWidget(
      user: friend,
      friendButton: friendButton.button,
      onFriendPush: onPush,
      showMessage: !friendButton.ignore && friendButton.isFriend,
      showFamilyCheckbox: !friendButton.ignore && friendButton.isFriend,
      allowExpandToggle: false,
    );
  }
}
