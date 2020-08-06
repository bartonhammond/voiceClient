import 'package:flutter/material.dart';

import 'package:voiceClient/app/profile_page/profile_page.dart';

import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/keys.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String stories = '/stories';
  static const String story = '/story';
}

class TabNavigatorProfile extends StatelessWidget {
  const TabNavigatorProfile(
      {this.navigatorKey, this.tabItem, this.onMessageCount});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;
  final dynamic onMessageCount;

  void _push(BuildContext context, String id) {
    final routeBuilders = _routeBuilders(context, id: id);

    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => routeBuilders[TabNavigatorRoutes.stories](
          context,
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(
    BuildContext context, {
    String id,
  }) {
    return {
      TabNavigatorRoutes.root: (context) => ProfilePage(
            key: Key(Keys.friendsPage),
            onPush: (id) => _push(
              context,
              id,
            ),
          ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute<dynamic>(
          builder: (context) => routeBuilders[routeSettings.name](
            context,
          ),
        );
      },
    );
  }
}
