import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:voiceClient/app/story_page.dart';
import 'package:voiceClient/common_widgets/fab/fab_bottom_app_bar.dart';
import 'package:voiceClient/common_widgets/navigator/tab_navigator_friends.dart';
import 'package:voiceClient/common_widgets/navigator/tab_navigator_messages.dart';
import 'package:voiceClient/common_widgets/navigator/tab_navigator_profile.dart';
import 'package:voiceClient/common_widgets/navigator/tab_navigator_stories.dart';

import 'package:voiceClient/constants/enums.dart';

import 'package:voiceClient/constants/keys.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //String _lastSelected = 'TAB: 0';
  TabItem _currentTab = TabItem.stories;

  final Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.stories: GlobalKey<NavigatorState>(),
    TabItem.friends: GlobalKey<NavigatorState>(),
    TabItem.messages: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
    TabItem.newStory: GlobalKey<NavigatorState>(),
  };

  void _selectedTab(TabItem item) {
    setState(() {
      _currentTab = item;
    });
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (context) => StoryPage(
                    key: Key(Keys.storyPage),
                    onFinish: null,
                  )),
        );
      },
      tooltip: 'Increment',
      child: Icon(Icons.add),
      elevation: 2.0,
    );
  }

  Widget _build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentTab].currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (_currentTab != TabItem.stories) {
            // select 'main' tab
            _selectedTab(TabItem.stories);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          buildOffStageNavigatorStories(TabItem.stories),
          buildOffStageNavigatorFriends(TabItem.friends),
          buildOffStageNavigatorMessages(TabItem.messages),
          buildOffStageNavigatorProfile(TabItem.profile),
          //_buildOffstageNavigator(TabItem.red),
          //_buildOffstageNavigator(TabItem.green),
          //_buildOffstageNavigator(TabItem.blue),
        ]),
        bottomNavigationBar: FABBottomAppBar(
          backgroundColor: NeumorphicTheme.currentTheme(context).baseColor,
          color: Colors.grey,
          selectedColor: Colors.red,
          notchedShape: CircularNotchedRectangle(),
          onTabSelected: _selectedTab,
          items: [
            FABBottomAppBarItem(
              iconData: Icons.menu,
              text: 'Stories',
            ),
            FABBottomAppBarItem(
              iconData: Icons.layers,
              text: 'Friends',
            ),
            FABBottomAppBarItem(
              iconData: Icons.dashboard,
              text: 'Notices',
              // badge: '0',
            ),
            FABBottomAppBarItem(
              iconData: Icons.info,
              text: 'Profile',
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFab(context), // This trailin
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }

  Widget buildOffStageNavigatorStories(TabItem item) {
    return Offstage(
      offstage: _currentTab != item,
      child: TabNavigatorStories(
        navigatorKey: _navigatorKeys[item],
        tabItem: item,
      ),
    );
  }

  Widget buildOffStageNavigatorFriends(TabItem item) {
    return Offstage(
      offstage: _currentTab != item,
      child: TabNavigatorFriends(
        navigatorKey: _navigatorKeys[item],
        tabItem: item,
      ),
    );
  }

  Widget buildOffStageNavigatorMessages(TabItem item) {
    return Offstage(
      offstage: _currentTab != item,
      child: TabNavigatorMessages(
        navigatorKey: _navigatorKeys[item],
        tabItem: item,
      ),
    );
  }

  Widget buildOffStageNavigatorProfile(TabItem item) {
    return Offstage(
      offstage: _currentTab != item,
      child: TabNavigatorProfile(
        navigatorKey: _navigatorKeys[item],
        tabItem: item,
      ),
    );
  }
}
