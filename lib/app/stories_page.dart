import 'dart:async';
import 'package:MyFamilyVoice/services/check_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/common_widgets/friend_widget.dart';
import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_story.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
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
  final nStories = 20;
  final ScrollController _scrollController = ScrollController();
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
      StoryFeedType.GLOBAL: true,
      StoryFeedType.FRIENDS: true,
      StoryFeedType.ME: true,
    },
    TypeStoriesView.oneFriend: {
      StoryFeedType.ALL: true,
      StoryFeedType.FAMILY: true,
      StoryFeedType.GLOBAL: true,
      StoryFeedType.FRIENDS: true,
      StoryFeedType.ME: true,
    },
    TypeStoriesView.me: {
      StoryFeedType.ALL: true,
      StoryFeedType.FAMILY: true,
      StoryFeedType.GLOBAL: true,
      StoryFeedType.FRIENDS: true,
      StoryFeedType.ME: true,
    },
  };
  Map<TypeStoriesView, Map<StoryFeedType, String>> searchResultsName = {
    TypeStoriesView.allFriends: {
      StoryFeedType.ALL: 'userFriendsStories',
      StoryFeedType.FAMILY: 'userFriendsStoriesFamily',
      StoryFeedType.GLOBAL: 'userFriendsStoriesGlobal',
      StoryFeedType.FRIENDS: 'userFriendsStoriesFriends',
      StoryFeedType.ME: 'userStoriesMe',
    },
    TypeStoriesView.oneFriend: {
      StoryFeedType.ALL: 'userStories',
      StoryFeedType.FAMILY: 'userStoriesFamily',
      StoryFeedType.GLOBAL: 'userStoriesGlobal',
      StoryFeedType.FRIENDS: 'userStoriesFriends',
    },
    TypeStoriesView.me: {
      StoryFeedType.ALL: 'userStoriesMe',
      StoryFeedType.FAMILY: 'userStoriesMeFamily',
      StoryFeedType.GLOBAL: 'userStoriesGlobal',
      StoryFeedType.FRIENDS: 'userStoriesFriends',
    },
  };

  @override
  void initState() {
    super.initState();

    if (getId() == null) {
      _typeStoryView = TypeStoriesView.allFriends;
    } else {
      if (getId() == graphQLAuth.getUserMap()['id']) {
        _typeStoryView = TypeStoriesView.me;
      } else {
        _typeStoryView = TypeStoriesView.oneFriend;
      }
    }
  }

  String getId() {
    if (widget.params == null) {
      return null;
    }
    if (widget.params['id'] == null) {
      return null;
    }
    return widget.params['id'];
  }

  Future<Map> getUserFromUserId() async {
    final Map<String, dynamic> user = <String, dynamic>{'empty': true};

    if (widget.params == null || getId() == null) {
      return user;
    }
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getUserByIdQL),
      variables: <String, dynamic>{
        'id': getId(),
      },
    );

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    return queryResult.data['User'][0];
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
    String gqlString;
    final _variables = <String, dynamic>{
      'email': graphQLAuth.getUser().email,
      'limit': nStories.toString(),
      'cursor': DateTime.now().toIso8601String(),
    };

    switch (_typeStoryView) {
      case TypeStoriesView.allFriends:
        switch (_storyFeedType) {
          case StoryFeedType.ALL:
            gqlString = getUserFriendsStoriesQL;
            break;
          case StoryFeedType.GLOBAL:
            gqlString = getUserFriendsStoriesGlobalQL;
            break;
          case StoryFeedType.FAMILY:
            gqlString = getUserFriendsStoriesFamilyQL;
            break;
          case StoryFeedType.FRIENDS:
            gqlString = getUserFriendsStoriesFriendsQL;
            break;
          case StoryFeedType.ME:
            gqlString = getUserStoriesMeQL;
        }
        break;

      case TypeStoriesView.oneFriend:
        switch (_storyFeedType) {
          case StoryFeedType.ALL:
            gqlString = getUserStoriesQL;
            _variables['email'] = user['email'];
            _variables['currentUserEmail'] = graphQLAuth.getUser().email;
            break;
          case StoryFeedType.GLOBAL:
            gqlString = getUserStoriesGlobalQL;
            _variables['email'] = user['email'];
            break;
          case StoryFeedType.FAMILY:
            gqlString = getUserStoriesFamilyQL;
            _variables['email'] = user['email'];
            _variables['currentUserEmail'] = graphQLAuth.getUser().email;
            break;
          case StoryFeedType.FRIENDS:
            gqlString = getUserStoriesFriendsQL;
            _variables['email'] = user['email'];
            break;
          case StoryFeedType.ME:
            // never happens
            break;
        }
        break;

      case TypeStoriesView.me:
        switch (_storyFeedType) {
          case StoryFeedType.ALL:
            gqlString = getUserStoriesMeQL;
            break;
          case StoryFeedType.GLOBAL:
            gqlString = getUserStoriesGlobalQL;
            break;
          case StoryFeedType.FAMILY:
            gqlString = getUserStoriesMeFamilyQL;
            break;
          case StoryFeedType.FRIENDS:
            gqlString = getUserStoriesFriendsQL;
            break;
          case StoryFeedType.ME:
            // never happens
            break;
        }
        break;
    }

    return QueryOptions(
      documentNode: gql(gqlString),
      variables: _variables,
    );
  }

  List<DropdownMenuItem<StoryFeedType>> getButtonItems() {
    final buttonItems = [
      DropdownMenuItem(
        child: Text(
          Strings.storiesPageAll.i18n,
        ),
        value: StoryFeedType.ALL,
      ),
      DropdownMenuItem(
        child: Text(
          Strings.storiesPageFamily.i18n,
        ),
        value: StoryFeedType.FAMILY,
      ),
      DropdownMenuItem(
        child: Text(
          Strings.storiesPageFriends.i18n,
        ),
        value: StoryFeedType.FRIENDS,
      ),
      DropdownMenuItem(
        child: Text(
          Strings.storiesPageGlobal.i18n,
        ),
        value: StoryFeedType.GLOBAL,
      )
    ];

    if (_typeStoryView == TypeStoriesView.allFriends) {
      buttonItems.add(
        DropdownMenuItem(
          child: Text(
            Strings.typeUserButtonMe.i18n,
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
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _staggeredViewSize = 2;
    int _crossAxisCount = 4;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _staggeredViewSize = 1;
        _crossAxisCount = 3;
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
            backgroundColor: Color(0xff00bcd4),
            title: Text(
              Strings.MFV.i18n,
            ),
            actions: checkProxy(graphQLAuth, context, () {
              setState(() {});
            }),
          ),
          drawer: getId() == null ? getDrawer(context) : null,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                getId() == null ? Container() : FriendWidget(user: user),
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

                      final List<dynamic> stories = List<dynamic>.from(
                          result.data[searchResultsName[_typeStoryView]
                              [_storyFeedType]]);

                      if (stories.isEmpty || stories.length < nStories) {
                        moreSearchResults[_typeStoryView][_storyFeedType] =
                            false;
                      }

                      return Expanded(
                        child: stories == null || stories.isEmpty
                            ? Center(
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(Strings.noResults.i18n),
                                    ],
                                  ),
                                ),
                              )
                            : StaggeredGridView.countBuilder(
                                controller: _scrollController,
                                itemCount: stories.length + 1,
                                primary: false,
                                crossAxisCount: _crossAxisCount,
                                mainAxisSpacing: 4.0,
                                crossAxisSpacing: 4.0,
                                itemBuilder: (context, index) {
                                  return index < stories.length
                                      ? StaggeredGridTileStory(
                                          index: index,
                                          crossAxisCount: _crossAxisCount,
                                          onPush: widget.onPush,
                                          showFriend: getId() == null,
                                          onDelete: () {
                                            setState(() {});
                                          },
                                          onProxySelected: () {
                                            setState(() {});
                                          },
                                          story: Map<String, dynamic>.from(
                                              stories[index]),
                                        )
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
}
