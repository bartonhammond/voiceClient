import 'dart:io';
import 'package:MyFamilyVoice/app/profile_page.dart';
import 'package:MyFamilyVoice/common_widgets/fab/unicorn_dialer.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
  enableVibration: true,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
    print('homePage.initState');
    super.initState();
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    if (graphQLAuth.getUserMap() == null ||
        (graphQLAuth.getUserMap()['image'] == null &&
            graphQLAuth.getUserMap()['name'] == null &&
            graphQLAuth.getUserMap()['home'] == null)) {
      _currentTab = TabItem.profile;
      _areTabsEnabled = false;
    } else {
      _currentTab = TabItem.stories;
      _areTabsEnabled = true;
    }

    eventBus.on<ProfileEvent>().listen((event) {
      if (mounted) {
        setState(() {
          _areTabsEnabled = event.isComplete;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () async {
      await requestMessagePermissions();
      await checkInitialMessage();
      await registerNotification();
    });
  }

  Future<void> requestMessagePermissions() async {
    final NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> checkInitialMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    final RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      printJson('initialMessage', initialMessage.data);
    } else {
      print('homePage.checkInitialMessage is null');
    }
  }

  Future<void> registerNotification() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('message $message');
      printJson('message', message.data);
    });

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        printJson('Message data', message.data);

        if (message.notification != null) {
          print(
              'Message also contained a notification ${message.notification.title}');
        }
        final RemoteNotification notification = message.notification;
        final AndroidNotification android = message.notification?.android;

        // If `onMessage` is triggered with a notification, construct our own
        // local notification to show to users using the created channel.
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  icon: android?.smallIcon,
                  // other properties...
                ),
              ));
        }
      },
    );
  }

  final Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.stories: GlobalKey<NavigatorState>(),
    TabItem.friends: GlobalKey<NavigatorState>(),
    TabItem.messages: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
    TabItem.newStory: GlobalKey<NavigatorState>(),
  };

  void _selectedTab(int tabIndex) {
    if (mounted) {
      setState(() {
        _currentTab = TabItem.values[tabIndex];
        if (_currentTab == TabItem.friends ||
            _currentTab == TabItem.stories ||
            _currentTab == TabItem.profile) {
          eventBus.fire(GetUserMessagesEvent());
        }
      });
    }
  }

  Widget _buildFab(BuildContext context) {
    final Map<String, dynamic> params = <String, dynamic>{};
    final childButtons = <UnicornButton>[];

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: 'Story',
        labelHasShadow: true,
        labelShadowColor: Colors.black38,
        currentButton: FloatingActionButton(
          key: Key('storyFloatingActionButton'),
          heroTag: 'story',
          backgroundColor: Color(0xff00bcd4),
          mini: true,
          child: Icon(Icons.history),
          onPressed: _areTabsEnabled
              ? () {
                  Navigator.push<dynamic>(context,
                      MaterialPageRoute<dynamic>(builder: (context) {
                    params['onFinish'] = () {
                      if (mounted) {
                        setState(() {});
                      }
                    };
                    return StoryPlay(
                      key: Key('storyPlay'),
                      params: params,
                    );
                  }));
                }
              : null,
        )));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: 'Book',
        labelHasShadow: true,
        labelShadowColor: Colors.black38,
        currentButton: FloatingActionButton(
            key: Key('bookFloatingActionButton'),
            heroTag: 'book',
            backgroundColor: Color(0xff00bcd4),
            mini: true,
            onPressed: _areTabsEnabled
                ? () {
                    Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (context) => ProfilePage(
                                key: Key(Keys.profilePage),
                                isBook: true,
                              )),
                    );
                  }
                : null,
            child: Icon(Icons.collections_bookmark))));

    return _areTabsEnabled
        ? UnicornDialer(
            parentButtonBackground: Color(0xff00bcd4),
            backgroundColor: Color(0xff00bcd4),
            orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(
              Icons.add,
            ),
            hasBackground: false,
            hasNotch: true,
            childPadding: 0,
            childButtons: childButtons,
          )
        : FloatingActionButton(
            backgroundColor: Color(0xff00bcd4),
            onPressed: () {},
            tooltip: Strings.toolTipFAB.i18n,
            child: Icon(
              Icons.add,
              color: _areTabsEnabled ? Colors.white : Colors.grey,
            ),
            elevation: 2.0,
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
