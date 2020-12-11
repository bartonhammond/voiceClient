import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:flutter/material.dart';

class StaggeredGridTileFriend extends StatelessWidget {
  const StaggeredGridTileFriend(
      {@required this.onPush,
      @required this.friend,
      @required this.friendButton,
      @required this.typeUser,
      @required this.onProxySelected,
      @required this.onBookDeleted});
  final ValueChanged<Map<String, dynamic>> onPush;
  final Map friend;
  final Widget friendButton;
  final TypeUser typeUser;
  final VoidCallback onProxySelected;
  final VoidCallback onBookDeleted;

  @override
  Widget build(BuildContext context) {
    return FriendWidget(
      user: friend,
      friendButton: friendButton,
      onFriendPush: onPush,
      showMessage: typeUser == TypeUser.friends || typeUser == TypeUser.family,
      showFamilyCheckbox:
          typeUser == TypeUser.friends || typeUser == TypeUser.family,
      allowExpandToggle: false,
      onProxySelected: onProxySelected,
    );
  }
}
