import 'package:MyFamilyVoice/common_widgets/friend_tag_widget.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:flutter/material.dart';

class StaggeredGridTileTag extends StatelessWidget {
  const StaggeredGridTileTag({
    @required this.friend,
    @required this.typeUser,
    this.onSelect,
    this.onDelete,
  });
  final Map friend;
  final TypeUser typeUser;
  final void Function(Map<String, dynamic>) onSelect;
  final void Function(Map<String, dynamic>) onDelete;

  @override
  Widget build(BuildContext context) {
    return FriendTagWidget(
      user: friend,
      typeUser: typeUser,
      onSelect: onSelect,
    );
  }
}
