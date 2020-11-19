import 'package:MyFamilyVoice/common_widgets/friend_tag_widget.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:flutter/material.dart';

class StaggeredGridTileTag extends StatelessWidget {
  const StaggeredGridTileTag({
    @required this.friend,
    @required this.typeUser,
  });
  final Map friend;
  final TypeUser typeUser;

  @override
  Widget build(BuildContext context) {
    return FriendTagWidget(
      user: friend,
      typeUser: typeUser,
    );
  }
}
