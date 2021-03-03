import 'dart:async';
import 'package:MyFamilyVoice/app/ads_global.dart';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/constants/admob.dart';
import 'package:MyFamilyVoice/constants/constants.dart';
import 'package:MyFamilyVoice/constants/globals.dart';
import 'package:MyFamilyVoice/ql/story/story_comments.dart';
import 'package:MyFamilyVoice/ql/story/story_original_user.dart';
import 'package:MyFamilyVoice/ql/story/story_reactions.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story/story_tags.dart';
import 'package:MyFamilyVoice/ql/story/story_user.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_book_author.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_search.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_story.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;

class Debouncer {
  Debouncer({this.milliseconds});
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  void run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
    return;
  }
}

class StoriesPage extends StatefulWidget {
  const StoriesPage({
    Key key,
    this.onPush,
    this.params,
  }) : super(key: key);

  final ValueChanged<Map<String, dynamic>> onPush;
  final Map<String, dynamic> params;
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  static AdsGlobal _storiesAdGlobal;
  final _nativeAdController = NativeAdmobController();

  final nStories = 20;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription storyWasAssignedToBookSubscription;

  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
  Map<String, dynamic> user;

  //Who is the audiance?
  TypeStoriesView _typeStoryView = TypeStoriesView.allFriends;

  //What kind of feed
  StoryFeedType _storyFeedType = StoryFeedType.ALL;

  Map<TypeStoriesView, Map<StoryFeedType, bool>> moreSearchResults = {
    TypeStoriesView.allFriends: {
      StoryFeedType.ALL: true,
      StoryFeedType.FAMILY: true,
      StoryFeedType.FRIENDS: true,
      StoryFeedType.ME: true,
    },
    TypeStoriesView.oneFriend: {
      StoryFeedType.ALL: true,
      StoryFeedType.FAMILY: true,
      StoryFeedType.FRIENDS: true,
      StoryFeedType.ME: true,
    },
    TypeStoriesView.me: {
      StoryFeedType.ALL: true,
      StoryFeedType.FAMILY: true,
      StoryFeedType.FRIENDS: true,
      StoryFeedType.ME: true,
    },
  };
  Map<TypeStoriesView, Map<StoryFeedType, String>> searchResultsName = {
    TypeStoriesView.allFriends: {
      StoryFeedType.ALL: 'userFriendsStories',
      StoryFeedType.FAMILY: 'userFriendsStoriesFamily',
      StoryFeedType.FRIENDS: 'userFriendsStoriesFriends',
      StoryFeedType.ME: 'userStoriesMe',
    },
    TypeStoriesView.oneFriend: {
      StoryFeedType.ALL: 'userStories',
      StoryFeedType.FAMILY: 'userStoriesFamily',
      StoryFeedType.FRIENDS: 'userStoriesFriends',
    },
    TypeStoriesView.me: {
      StoryFeedType.ALL: 'userStoriesMe',
      StoryFeedType.FAMILY: 'userStoriesMeFamily',
      StoryFeedType.FRIENDS: 'userStoriesMeFriends',
    },
  };

  VoidCallback _refetchQuery;

  final StoryUser storyUser = StoryUser();

  final StoryOriginalUser storyOriginalUser = StoryOriginalUser();
  final StoryComments storyComments = StoryComments();
  final StoryReactions storyReactions = StoryReactions();
  final StoryTags storyTags = StoryTags();

  StoryQl storyQl;

  @override
  void initState() {
    super.initState();
    //If update this, then also coordinate w/ sgts callback()
    storyQl = StoryQl(
      storyUser: storyUser,
      storyOriginalUser: storyOriginalUser,
      storyComments: storyComments,
      storyReactions: storyReactions,
      storyTags: storyTags,
    );

    storyWasAssignedToBookSubscription =
        eventBus.on<StoryWasAssignedToBook>().listen((event) {
      setState(() {
        if (_refetchQuery != null) {
          _refetchQuery();
        }
      });
    });

    if (getEmailFromParams() == null) {
      _typeStoryView = TypeStoriesView.allFriends;
    } else {
      if (getEmailFromParams() == graphQLAuth.getUserMap()['email']) {
        _typeStoryView = TypeStoriesView.me;
      } else {
        _typeStoryView = TypeStoriesView.oneFriend;
      }
    }
  }

  @override
  void dispose() {
    storyWasAssignedToBookSubscription.cancel();
    super.dispose();
  }

  String getEmailFromParams() {
    if (widget.params == null) {
      return null;
    }
    if (widget.params['email'] == null) {
      return null;
    }
    return widget.params['email'];
  }

  Future<Map> getUserFromUserId() async {
    final Map<String, dynamic> user = <String, dynamic>{'empty': true};

    if (widget.params == null || getEmailFromParams() == null) {
      return user;
    }
    final UserBookAuthor userBookAuthor = UserBookAuthor();
    final UserFriends userFriends = UserFriends();
    final UserQl userQL = UserQl(
      core: true,
      userBookAuthor: userBookAuthor,
      userFriends: userFriends,
    );

    final UserSearch userSearch = UserSearch.init(
      GraphQLProvider.of(context).value,
      userQL,
      getEmailFromParams(),
    );
    userSearch.setQueryName('getUserByEmail');
    userSearch.setVariables(<String, dynamic>{
      'currentUserEmail': 'String!',
    });

    return await userSearch.getItem(<String, dynamic>{
      'currentUserEmail': getEmailFromParams(),
    });
  }

  String getCursor(List<dynamic> _list) {
    String datetime;
    if (_list == null || _list.isEmpty) {
      datetime = DateTime.now().toIso8601String();
    } else {
      datetime = _list[_list.length - 1]['updated']['formatted'];
    }
    return datetime;
  }

  void isThereMoreSearchResults(dynamic fetchMoreResultData) {
    moreSearchResults[_typeStoryView][_storyFeedType] =
        fetchMoreResultData[searchResultsName[_typeStoryView][_storyFeedType]]
                .length >
            0;
  }

  Widget getLoadMoreButton(
    FetchMore fetchMore,
    List<dynamic> activities,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
      child: CustomRaisedButton(
        text: Strings.loadMore.i18n,
        icon: Icon(
          Icons.arrow_downward,
          color: Colors.white,
        ),
        onPressed: () {
          final FetchMoreOptions opts = FetchMoreOptions(
            variables: <String, dynamic>{
              'cursor': getCursor(activities),
            },
            updateQuery:
                (dynamic previousResultData, dynamic fetchMoreResultData) {
              final List<dynamic> data = <dynamic>[
                ...previousResultData[searchResultsName[_typeStoryView]
                    [_storyFeedType]],
                ...fetchMoreResultData[searchResultsName[_typeStoryView]
                    [_storyFeedType]]
              ];
              isThereMoreSearchResults(fetchMoreResultData);
              fetchMoreResultData[searchResultsName[_typeStoryView]
                  [_storyFeedType]] = data;

              return fetchMoreResultData;
            },
          );
          fetchMore(opts);
        },
      ),
    );
  }

  QueryOptions getQueryOptions(GraphQLAuth graphQLAuth) {
    final _values = <String, dynamic>{
      'currentUserEmail': graphQLAuth.getUser().email,
      'limit': nStories.toString(),
      'cursor': DateTime.now().toIso8601String(),
    };
    final StorySearch storySearch = StorySearch.init(
      null,
      storyQl,
      graphQLAuth.getUser().email,
    );
    switch (_typeStoryView) {
      case TypeStoriesView.allFriends:
        switch (_storyFeedType) {
          case StoryFeedType.ALL:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
            });
            storySearch.setQueryName('userFriendsStories');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.FAMILY:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
            });
            storySearch.setQueryName('userFriendsStoriesFamily');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.FRIENDS:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
            });
            storySearch.setQueryName('userFriendsStoriesFriends');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.ME:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
            });
            storySearch.setQueryName('userStoriesMe');
            return storySearch.getQueryOptions(_values);
        }
        break;

      case TypeStoriesView.oneFriend:
        switch (_storyFeedType) {
          case StoryFeedType.ALL:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
              'friendEmail': 'String!',
            });
            _values['currentUserEmail'] = graphQLAuth.getUser().email;
            _values['friendEmail'] = user['email'];
            storySearch.setQueryName('userStories');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.FAMILY:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
              'friendEmail': 'String!',
            });
            _values['currentUserEmail'] = graphQLAuth.getUser().email;
            _values['friendEmail'] = user['email'];
            storySearch.setQueryName('userStoriesFamily');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.FRIENDS:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
              'friendEmail': 'String!',
            });
            _values['currentUserEmail'] = graphQLAuth.getUser().email;
            _values['friendEmail'] = user['email'];
            storySearch.setQueryName('userStoriesFriends');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.ME:
            // never happens
            break;
        }
        break;

      case TypeStoriesView.me:
        switch (_storyFeedType) {
          case StoryFeedType.ALL:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
            });
            storySearch.setQueryName('userStoriesMe');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.FAMILY:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
            });
            storySearch.setQueryName('userStoriesMeFamily');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.FRIENDS:
            storySearch.setVariables(<String, dynamic>{
              'currentUserEmail': 'String!',
              'limit': 'String!',
              'cursor': 'String!',
            });
            storySearch.setQueryName('userStoriesMeFriends');
            return storySearch.getQueryOptions(_values);
            break;
          case StoryFeedType.ME:
            // never happens
            break;
        }
        break;
    }

    return null;
  }

  List<DropdownMenuItem<StoryFeedType>> getButtonItems() {
    final buttonItems = [
      DropdownMenuItem(
        child: Text(
          Strings.storiesPageAll.i18n,
          key: Key('storiesPageAll'),
        ),
        value: StoryFeedType.ALL,
      ),
      DropdownMenuItem(
        child: Text(
          Strings.storiesPageFamily.i18n,
          key: Key('storiesPageFamily'),
        ),
        value: StoryFeedType.FAMILY,
      ),
      DropdownMenuItem(
        child: Text(
          Strings.storiesPageFriends.i18n,
          key: Key('storiesPageFriends'),
        ),
        value: StoryFeedType.FRIENDS,
      ),
    ];

    if (_typeStoryView == TypeStoriesView.allFriends) {
      buttonItems.add(
        DropdownMenuItem(
          child: Text(
            Strings.typeUserButtonMe.i18n,
            key: Key('storiesPageMe'),
          ),
          value: StoryFeedType.ME,
        ),
      );
    }

    return buttonItems;
  }

  Widget getDropDownStoryTypeButtons() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<StoryFeedType>(
        key: Key('storiesPageDropDown'),
        value: _storyFeedType,
        items: getButtonItems(),
        onChanged: (value) {
          setState(() {
            _storyFeedType = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _storiesAdGlobal ??= AdsGlobal(context);
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _staggeredViewSize = 2;
    int _crossAxisCount = 4;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _staggeredViewSize = 1;
        _crossAxisCount = 2;
        break;
      case DeviceScreenType.watch:
        _crossAxisCount = 1;
        break;
      default:
        _staggeredViewSize = 1;
        _crossAxisCount = 1;
    }

    return FutureBuilder(
      future: getUserFromUserId(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.createMessage(
              userEmail: graphQLAuth.getUser().email,
              source: 'stories_page',
              shortMessage: snapshot.error.toString(),
              stackTrace: StackTrace.current.toString());
          return Text('\nErrors: \n  ' + snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        user = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Constants.backgroundColor,
            title: Text(
              Strings.MFV.i18n,
            ),
          ),
          drawer: getEmailFromParams() == null ? DrawerWidget() : null,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              key: Key('storiesPageColumn'),
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                getEmailFromParams() == null
                    ? Container()
                    : FriendWidget(
                        user: user,
                      ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    getDropDownStoryTypeButtons(),
                  ],
                ),
                Query(
                    options: getQueryOptions(graphQLAuth),
                    builder: (
                      QueryResult result, {
                      VoidCallback refetch,
                      FetchMore fetchMore,
                    }) {
                      if (result.loading && result.data == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (result.hasException) {
                        logger.createMessage(
                            userEmail: graphQLAuth.getUser().email,
                            source: 'stories_page',
                            shortMessage: result.exception.toString(),
                            stackTrace: StackTrace.current.toString());
                        return Text(
                            '\nErrors: \n  ' + result.exception.toString());
                      }
                      _refetchQuery = refetch;
                      final List<dynamic> stories = List<dynamic>.from(
                          result.data[searchResultsName[_typeStoryView]
                              [_storyFeedType]]);

                      if (stories.isEmpty || stories.length < nStories) {
                        moreSearchResults[_typeStoryView][_storyFeedType] =
                            false;
                      }

                      if (stories.isEmpty) {
                        eventBus.fire(BookHasNoStories(user['id']));
                      }
                      final int _storiesLength = stories.length + 1;
                      _storiesAdGlobal.randomizeFrequency();

                      return Expanded(
                        key: Key('storiesPageExpanded'),
                        child: stories == null || stories.isEmpty
                            ? Center(
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(Strings.noResults.i18n,
                                          key: Key('noMessages')),
                                    ],
                                  ),
                                ),
                              )
                            : StaggeredGridView.countBuilder(
                                controller: _scrollController,
                                itemCount: _storiesLength,
                                primary: false,
                                crossAxisCount: _crossAxisCount,
                                mainAxisSpacing: 4.0,
                                crossAxisSpacing: 4.0,
                                itemBuilder: (context, index) {
                                  return index < stories.length
                                      ? _storiesAdGlobal.showAd()
                                          ? getAdmobNative(
                                              context,
                                              stories,
                                              index,
                                              _crossAxisCount,
                                            )
                                          : getStaggered(
                                              stories, index, _crossAxisCount)
                                      : moreSearchResults[_typeStoryView]
                                              [_storyFeedType]
                                          ? getLoadMoreButton(
                                              fetchMore, stories)
                                          : Container();
                                },
                                staggeredTileBuilder: (index) =>
                                    StaggeredTile.fit(_staggeredViewSize),
                              ),
                      );
                    })
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getStaggered(List<dynamic> stories, int index, int _crossAxisCount) {
    //if email is available, we're looking at the stories
    //of one person, basically you're on the Users page
    //after clicking on a user
    //If the story is from a book and the original author
    //is not who we're looking at, show who the author is
    final bool bookOriginalUserIsCurrent = getEmailFromParams() != null &&
        stories[index]['user']['isBook'] &&
        stories[index]['originalUser']['email'] != getEmailFromParams();
    final bool showFriend =
        getEmailFromParams() == null || bookOriginalUserIsCurrent;

    //see globals
    if (bookOriginalUserIsCurrent) {
      collapseFriendWidget = true;
    }
    return StaggeredGridTileStory(
      index: index,
      crossAxisCount: _crossAxisCount,
      onPush: widget.onPush,
      showFriend: showFriend,
      onDelete: () {
        setState(() {});
      },
      onBanned: () {
        setState(() {});
      },
      story: Map<String, dynamic>.from(stories[index]),
    );
  }

  Widget getAdmobNative(
    BuildContext context,
    List<dynamic> stories,
    int index,
    int _crossAxisCount,
  ) {
    String admobId;
    final config = AppConfig.of(context);
    if (config.flavorName == 'Prod') {
      if (Theme.of(context).platform == TargetPlatform.android) {
        admobId = AdMob.androidAdUnitIdNative;
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        admobId = AdMob.iosAdUnitIdNative;
      }
    } else {
      admobId = NativeAd.testAdUnitId;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: EdgeInsets.all(8),
          height: 330,
          // color: Colors.cyanAccent,
          child: NativeAdmob(
            options: NativeAdmobOptions(
                bodyTextStyle:
                    const NativeTextStyle(fontSize: 12, color: Colors.black),
                adLabelTextStyle: NativeTextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  backgroundColor: Constants.backgroundColor,
                ),
                callToActionStyle: NativeTextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  backgroundColor: Constants.backgroundColor,
                )),
            key: Key('nativeAdMob-$index'),
            adUnitID: admobId,
            controller: _nativeAdController,
            type: NativeAdmobType.full,
            loading: Center(child: CircularProgressIndicator()),
            error: Text('failed to load'),
          ),
        ),
        getStaggered(stories, index, _crossAxisCount)
      ],
    );
  }
}
