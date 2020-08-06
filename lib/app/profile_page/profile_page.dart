import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:voiceClient/app/profile_page/profile_page_other.dart';
import 'package:voiceClient/app/profile_page/profile_page_small.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    Key key,
    this.id,
    this.onPush,
  }) : super(key: key);
  final ValueChanged<String> onPush;
  final String id;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
        mobile: (BuildContext context) =>
            ProfilePageOther(key: key, id: id, onPush: onPush),
        tablet: (BuildContext context) =>
            ProfilePageOther(key: key, id: id, onPush: onPush),
        desktop: (BuildContext context) =>
            ProfilePageOther(key: key, id: id, onPush: onPush),
        watch: (BuildContext context) =>
            ProfilePageSmall(key: key, id: id, onPush: onPush));
  }
}
