import 'package:flutter/material.dart';

import 'package:voiceClient/app/stories_page/stories_page.dart'
    show StoriesPage;
import 'package:voiceClient/app/story_play.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/keys.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigatorStories extends StatelessWidget {
  const TabNavigatorStories({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(
    BuildContext context,
    Map<String, dynamic> params,
  ) {
    final routeBuilders = _routeBuilders(
      context,
      params: params,
    );

    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => routeBuilders[TabNavigatorRoutes.detail](context),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(
    BuildContext context, {
    Map<String, dynamic> params,
  }) {
    return {
      TabNavigatorRoutes.root: (context) => StoriesPage(
            onPush: (params) => _push(
              context,
              params,
            ),
            params: params,
            key: Key(Keys.storiesPage),
          ),
      TabNavigatorRoutes.detail: (context) => StoryPlay(
            key: UniqueKey(),
            params: params,
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
          builder: (context) => routeBuilders[routeSettings.name](context),
        );
      },
    );
  }
}