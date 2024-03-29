import 'package:flutter/material.dart';

import 'package:MyFamilyVoice/app/friends_page.dart' show FriendsPage;
import 'package:MyFamilyVoice/app/stories_page.dart' show StoriesPage;
import 'package:MyFamilyVoice/app/story_play.dart';

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/keys.dart';

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

  void _push(BuildContext context, Map<String, dynamic> params) {
    final routeBuilders = _routeBuilders(
      context,
      params: params,
    );

    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => routeBuilders[TabNavigatorRoutes.stories](
          context,
        ),
      ),
    );
  }

  void _pushStory(BuildContext context, Map<String, dynamic> params) {
    final routeBuilders = _routeBuilders(
      context,
      params: params,
    );

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
    Map<String, dynamic> params,
  }) {
    return {
      TabNavigatorRoutes.root: (context) => FriendsPage(
            key: Key(Keys.friendsPage),
            onPush: (params) => _push(
              context,
              params,
            ),
          ),
      TabNavigatorRoutes.stories: (context) => StoriesPage(
            key: Key(Keys.storiesPage),
            onPush: (params) => _pushStory(
              context,
              params,
            ),
            params: params,
          ),
      TabNavigatorRoutes.story: (context) => StoryPlay(
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
          builder: (context) => routeBuilders[routeSettings.name](
            context,
          ),
        );
      },
    );
  }
}
