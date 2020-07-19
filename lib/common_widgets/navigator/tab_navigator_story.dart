import 'package:flutter/material.dart';

import 'package:voiceClient/app/story_page.dart';
import 'package:voiceClient/constants/enums.dart';

class TabNavigatorRoutes {
  static const String root = '/';
}

class TabNavigatorStory extends StatelessWidget {
  const TabNavigatorStory({this.onFinish, this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;
  final ValueChanged<TabItem> onFinish;

  Map<String, WidgetBuilder> _routeBuilders(
    BuildContext context,
  ) {
    return {
      TabNavigatorRoutes.root: (context) => StoryPage(onFinish: onFinish),
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
