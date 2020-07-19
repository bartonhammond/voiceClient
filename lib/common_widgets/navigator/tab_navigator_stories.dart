import 'package:flutter/material.dart';

import 'package:voiceClient/app/stories_page.dart';
import 'package:voiceClient/app/story_page.dart';
import 'package:voiceClient/constants/enums.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigatorStories extends StatelessWidget {
  const TabNavigatorStories({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context, {Map<String, String> map}) {
    final routeBuilders = _routeBuilders(
      context,
      id: map['id'],
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
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
    String id,
    String imageUrl,
    String audioUrl,
  }) {
    final Map map = <String, String>{};
    map['id'] = id;
    map['imageUrl'] = imageUrl;
    map['audioUrl'] = audioUrl;
    return {
      TabNavigatorRoutes.root: (context) => StoriesPage(
            onPush: (map) => _push(context, map: map),
          ),
      TabNavigatorRoutes.detail: (context) => StoryPage(
            id: id,
            imageUrl: imageUrl,
            audioUrl: audioUrl,
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
