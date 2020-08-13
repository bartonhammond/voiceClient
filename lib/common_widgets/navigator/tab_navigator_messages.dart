import 'package:flutter/material.dart';

import 'package:voiceClient/app/messages_page.dart' show MessagesPage;

import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/keys.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String message = '/message';
}

class TabNavigatorMessages extends StatelessWidget {
  const TabNavigatorMessages({
    this.navigatorKey,
    this.tabItem,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context, String id) {
    final routeBuilders = _routeBuilders(context, id: id);

    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => routeBuilders[TabNavigatorRoutes.message](
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
      TabNavigatorRoutes.root: (context) => MessagesPage(
            key: Key(Keys.messagesPage),
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