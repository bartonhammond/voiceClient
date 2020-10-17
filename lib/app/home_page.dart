import 'package:flutter/material.dart';
import 'package:MyFamilyVoice/app/story_play.dart';
import 'package:MyFamilyVoice/common_widgets/fab/fab_bottom_app_bar.dart';

import 'package:MyFamilyVoice/common_widgets/navigator/tab_navigator_friends.dart';
import 'package:MyFamilyVoice/common_widgets/navigator/tab_navigator_messages.dart';
import 'package:MyFamilyVoice/common_widgets/navigator/tab_navigator_profile.dart';
import 'package:MyFamilyVoice/common_widgets/navigator/tab_navigator_stories.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab;
  bool _areTabsEnabled = true;

  @override
  void initState() {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    if (graphQLAuth.getUserMap()['image'] == null &&
        graphQLAuth.getUserMap()['name'] == null &&
        graphQLAuth.getUserMap()['home'] == null) {
      _currentTab = TabItem.profile;
      _areTabsEnabled = false;
    } else {
      _currentTab = TabItem.stories;
      _areTabsEnabled = true;
    }
    eventBus.on<ProfileEvent>().listen((event) {
      setState(() {
        _areTabsEnabled = event.isComplete;
      });
    });
    super.initState();
  }

  final Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.stories: GlobalKey<NavigatorState>(),
    TabItem.friends: GlobalKey<NavigatorState>(),
    TabItem.messages: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
    TabItem.newStory: GlobalKey<NavigatorState>(),
  };

  void _selectedTab(int tabIndex) {
    setState(() {
      _currentTab = TabItem.values[tabIndex];
    });
  }

  Widget _buildFab(BuildContext context) {
    final Map<String, dynamic> params = <String, dynamic>{};
    return FloatingActionButton(
      backgroundColor: Color(0xff00bcd4),
      onPressed: _areTabsEnabled
          ? () {
              Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (context) => StoryPlay(
                          key: Key('storyPlay'),
                          params: params,
                        )),
              );
            }
          : null,
      tooltip: Strings.toolTipFAB.i18n,
      child: Icon(
        Icons.add,
        color: _areTabsEnabled ? Colors.white : Colors.grey,
      ),
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
            _selectedTab(TabItem.stories.index);
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
        ]),
        bottomNavigationBar: FABBottomAppBar(
          backgroundColor: Color(0xff00bcd4),
          color: _areTabsEnabled ? Colors.white : Colors.grey,
          selectedColor: Colors.black,
          notchedShape: CircularNotchedRectangle(),
          onTabSelected: _selectedTab,
          selectedIndex: _currentTab.index,
          items: [
            FABBottomAppBarItem(
              enabled: _areTabsEnabled,
              iconData: Icons.menu,
              text: Strings.storiesTabName.i18n,
            ),
            FABBottomAppBarItem(
              enabled: _areTabsEnabled,
              iconData: Icons.layers,
              text: Strings.friendsTabName.i18n,
            ),
            FABBottomAppBarItem(
              enabled: _areTabsEnabled,
              iconData: Icons.dashboard,
              text: Strings.noticesTabName.i18n,
              // badge: '0',
            ),
            FABBottomAppBarItem(
              enabled: true,
              iconData: Icons.info,
              text: Strings.profileTabName.i18n,
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
      child: _currentTab != item
          ? Container()
          : TabNavigatorStories(
              navigatorKey: _navigatorKeys[item],
              tabItem: item,
            ),
    );
  }

  Widget buildOffStageNavigatorFriends(TabItem item) {
    return Offstage(
      offstage: _currentTab != item,
      child: _currentTab != item
          ? Container()
          : TabNavigatorFriends(
              navigatorKey: _navigatorKeys[item],
              tabItem: item,
            ),
    );
  }

  Widget buildOffStageNavigatorMessages(TabItem item) {
    return Offstage(
      offstage: _currentTab != item,
      child: _currentTab != item
          ? Container()
          : TabNavigatorMessages(
              navigatorKey: _navigatorKeys[item],
              tabItem: item,
            ),
    );
  }

  Widget buildOffStageNavigatorProfile(TabItem item) {
    return Offstage(
      offstage: _currentTab != item,
      child: _currentTab != item
          ? Container()
          : TabNavigatorProfile(
              navigatorKey: _navigatorKeys[item],
              tabItem: item,
            ),
    );
  }
}
