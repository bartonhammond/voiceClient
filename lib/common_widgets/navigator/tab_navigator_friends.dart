import 'package:flutter/material.dart';

import 'package:voiceClient/app/friends_page.dart' show FriendsPage;
import 'package:voiceClient/app/stories_page.dart' show StoriesPage;
import 'package:voiceClient/app/story_play.dart';

import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/keys.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String stories = '/stories';
  static const String story = '/story';
}

class TabNavigatorFriends extends StatelessWidget {
  const TabNavigatorFriends(
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

  void _pushStory(BuildContext context, String id) {
    final routeBuilders = _routeBuilders(context, id: id);

    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => routeBuilders[TabNavigatorRoutes.story](
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
      TabNavigatorRoutes.root: (context) => FriendsPage(
            key: Key(Keys.friendsPage),
            onPush: (id) => _push(
              context,
              id,
            ),
          ),
      TabNavigatorRoutes.stories: (context) => StoriesPage(
          key: Key(Keys.storiesPage),
          onPush: (id) => _pushStory(
                context,
                id,
              ),
          userId: id),
      TabNavigatorRoutes.story: (context) => StoryPlay(
            key: Key(Keys.storyPage),
            id: id,
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
