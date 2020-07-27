import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:voiceClient/app/story_page.dart';
import 'package:voiceClient/common_widgets/fab/fab_bottom_app_bar.dart';
import 'package:voiceClient/common_widgets/fab/fab_with_icons.dart';
import 'package:voiceClient/common_widgets/fab/layout.dart';
import 'package:voiceClient/common_widgets/navigator/tab_navigator_friends.dart';
import 'package:voiceClient/common_widgets/navigator/tab_navigator_messages.dart';
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
  bool _isVisible = true;
  int _newMessageCount = 0;

  final Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.stories: GlobalKey<NavigatorState>(),
    TabItem.friends: GlobalKey<NavigatorState>(),
    TabItem.messages: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
    TabItem.newStory: GlobalKey<NavigatorState>(),
  };

  void _setMessageCount(int count) {
    setState(() {
      _newMessageCount = count;
    });
  }

  void _selectedTab(TabItem item) {
    setState(() {
      _currentTab = item;
    });
  }

  void _setVisible(bool value) {
    setState(() {
      _isVisible = value;
    });
  }

  void _selectedFab(Map<String, dynamic> map) {
    setState(() {
      switch (map['index']) {
        case 0:
          setState(() {
            _isVisible = false;
          });

          Navigator.push<dynamic>(
            map['context'],
            MaterialPageRoute<dynamic>(
                builder: (context) => StoryPage(
                      key: Key(Keys.storyPage),
                      onFinish: _setVisible,
                    )),
          );
          break;
      }
    });
  }

  Widget _buildFab(BuildContext context) {
    final icons = [Icons.sms, Icons.mail, Icons.phone];
    return Visibility(
      visible: _isVisible,
      child: AnchoredOverlay(
        showOverlay: true,
        overlayBuilder: (context, offset) {
          return CenterAbout(
            position: Offset(offset.dx, offset.dy - icons.length * 35.0),
            child: FabWithIcons(
              icons: icons,
              onIconTapped: _selectedFab,
            ),
          );
        },
        child: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Increment',
          child: Icon(Icons.add),
          elevation: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            FABBottomAppBarItem(iconData: Icons.menu, text: 'Stories'),
            FABBottomAppBarItem(iconData: Icons.layers, text: 'Friends'),
            FABBottomAppBarItem(
              iconData: Icons.dashboard,
              text: 'Messages',
              badge: _newMessageCount.toString(),
            ),
            FABBottomAppBarItem(iconData: Icons.info, text: 'Profile'),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFab(context), // This trailin
      ),
    );
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
}
