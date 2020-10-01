import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/friend_widget.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_story.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:voiceClient/services/service_locator.dart';

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

class ResultTypes {
  ResultTypes(
    this._typeStoriesView,
    this._typeSearch,
  );

  TypeSearch _typeSearch;
  final TypeStoriesView _typeStoriesView;

  final String _userFriendStoriesByDate = 'userFriendsStories';
  final String _userFriendStoriesByHashTag = 'userFriendsStoriesByHashtag';
  final String _userStoriesByDate = 'userStories';
  final String _userStoriesByHashTag = 'userStoriesByHashtag';

  bool _userFriendStoriesByDateHasMore = true;
  bool _userFriendStoriesByHashTagHasMore = true;
  bool _userStoriesByDateHasMore = true;
  bool _userStoriesByHashTagHasMore = true;

  TypeStoriesView getTypeStoriesView() {
    return _typeStoriesView;
  }

  void setHasMore(bool value) {
    if (_typeStoriesView == TypeStoriesView.allFriends) {
      if (_typeSearch == TypeSearch.hashtag) {
        _userFriendStoriesByHashTagHasMore = value;
      } else {
        _userFriendStoriesByDateHasMore = value;
      }
    }
    if (_typeStoriesView == TypeStoriesView.oneFriend) {
      if (_typeSearch == TypeSearch.hashtag) {
        _userStoriesByHashTagHasMore = value;
      } else {
        _userStoriesByDateHasMore = value;
      }
    }
  }

  bool getHasMore() {
    if (_typeStoriesView == TypeStoriesView.allFriends) {
      if (_typeSearch == TypeSearch.hashtag) {
        return _userFriendStoriesByHashTagHasMore;
      } else {
        return _userFriendStoriesByDateHasMore;
      }
    }
    if (_typeStoriesView == TypeStoriesView.oneFriend) {
      if (_typeSearch == TypeSearch.hashtag) {
        return _userStoriesByHashTagHasMore;
      }
    }
    return _userStoriesByDateHasMore;
  }

  void setTypeSearch(TypeSearch typeSearch) {
    _typeSearch = typeSearch;
  }

  TypeSearch getTypeSearch() {
    return _typeSearch;
  }

  String getResultType() {
    if (_typeStoriesView == TypeStoriesView.allFriends) {
      if (_typeSearch == TypeSearch.hashtag) {
        return _userFriendStoriesByHashTag;
      } else {
        return _userFriendStoriesByDate;
      }
    }
    if (_typeStoriesView == TypeStoriesView.oneFriend) {
      if (_typeSearch == TypeSearch.hashtag) {
        return _userStoriesByHashTag;
      }
    }
    return _userStoriesByDate;
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
  Map<String, dynamic> user;
  final _debouncer = Debouncer(milliseconds: 500);
  String _searchString;

  ResultTypes _resultTypes;

  @override
  void initState() {
    super.initState();
    _searchString = '*';
    if (getId() == null) {
      _resultTypes = ResultTypes(
        TypeStoriesView.allFriends,
        TypeSearch.date,
      );
    } else {
      _resultTypes = ResultTypes(
        TypeStoriesView.oneFriend,
        TypeSearch.date,
      );
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
    print('stories_page getUserFromUserId');
    final Map<String, dynamic> user = <String, dynamic>{'empty': true};

    if (widget.params == null || getId() == null) {
      print('stories_page getUserFromUserId return user(empty)');
      return user;
    }
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getUserById),
      variables: <String, dynamic>{'id': getId()},
    );

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    print('stories_page getUserFromUserId returning User {map}');
    return queryResult.data['User'][0];
  }

  Widget getDropDownTypeSearchButtons() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<TypeSearch>(
        value: _resultTypes.getTypeSearch(),
        items: [
          DropdownMenuItem(
              child: Text(
                Strings.dateLabel.i18n,
              ),
              value: TypeSearch.date),
          DropdownMenuItem(
            child: Text(
              Strings.tagsLabel.i18n,
            ),
            value: TypeSearch.hashtag,
          ),
        ],
        onChanged: (value) {
          setState(() {
            _resultTypes.setTypeSearch(value);
          });
        },
      ),
    );
  }

  Widget buildSearchField() {
    return Flexible(
      fit: FlexFit.loose,
      child: TextField(
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff00bcd4))),
            labelStyle: TextStyle(color: Color(0xff00bcd4)),
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xff00bcd4))),
            contentPadding: EdgeInsets.all(15.0),
            hintText: Strings.searchByTagsHint.i18n,
            hintStyle: TextStyle(color: Color(0xff00bcd4))),
        onChanged: (string) {
          _debouncer.run(() {
            setState(() {
              if (string.isEmpty) {
                _searchString = '*';
              } else {
                _searchString = '$string*';
              }
            });
          });
        },
      ),
    );
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

  Widget getLoadMoreButton(
    FetchMore fetchMore,
    List<dynamic> activities,
  ) {
    return CustomRaisedButton(
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
              _resultTypes.setHasMore(
                  fetchMoreResultData[_resultTypes.getResultType()].length > 0);

              final List<dynamic> data = <dynamic>[
                ...previousResultData[_resultTypes.getResultType()],
                ...fetchMoreResultData[_resultTypes.getResultType()],
              ];

              fetchMoreResultData[_resultTypes.getResultType()] = data;

              return fetchMoreResultData;
            },
          );
          fetchMore(opts);
        });
  }

  QueryOptions getQueryOptions(GraphQLAuth graphQLAuth) {
    print('stories_page getQueryOptions');
    if (_resultTypes.getTypeStoriesView() == TypeStoriesView.allFriends) {
      if (_resultTypes.getTypeSearch() == TypeSearch.hashtag) {
        return QueryOptions(
          documentNode: gql(getUserFriendsStoriesByHashtagQL),
          variables: <String, dynamic>{
            'email': graphQLAuth.getUser().email,
            'searchString': _searchString,
            'limit': nStories.toString(),
            'cursor': DateTime.now().toIso8601String(),
          },
        );
      } else {
        return QueryOptions(
          documentNode: gql(getUserFriendsStories),
          variables: <String, dynamic>{
            'email': graphQLAuth.getUser().email,
            'limit': nStories.toString(),
            'cursor': DateTime.now().toIso8601String(),
          },
        );
      }
    }
    if (_resultTypes.getTypeStoriesView() == TypeStoriesView.oneFriend) {
      if (_resultTypes.getTypeSearch() == TypeSearch.hashtag) {
        return QueryOptions(
          documentNode: gql(getUserStoriesByHashtagQL),
          variables: <String, dynamic>{
            'email': user['email'],
            'searchString': _searchString,
            'limit': nStories.toString(),
            'cursor': DateTime.now().toIso8601String(),
          },
        );
      }
    }
    return QueryOptions(
      documentNode: gql(getUserStories),
      variables: <String, dynamic>{
        'email': user['email'],
        'limit': nStories.toString(),
        'cursor': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('stories_page build');
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

    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    return FutureBuilder(
      future: getUserFromUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print('stories_page snapshot !hasData');
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          print('stories_page snapshot has error');
          throw snapshot.error;
        }
        print('stories_page snapshot has data');
        user = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff00bcd4),
            title: Text(
              Strings.MFV.i18n,
            ),
          ),
          drawer: getId() == null ? getDrawer(context) : null,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                getId() == null
                    ? Container()
                    : buildFriend(
                        context,
                        user,
                      ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    getDropDownTypeSearchButtons(),
                    _resultTypes.getTypeSearch() == TypeSearch.date
                        ? Container()
                        : buildSearchField()
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
                        print(StackTrace.current);
                        return Text(
                            '\nErrors: \n  ' + result.exception.toString());
                      }

                      final List<dynamic> stories = List<dynamic>.from(
                          result.data[_resultTypes.getResultType()]);

                      if (stories.isEmpty || stories.length < nStories) {
                        _resultTypes.setHasMore(false);
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
                                          onPush: widget.onPush,
                                          showFriend: getId() == null,
                                          onDelete: () {
                                            setState(() {});
                                          },
                                          story: Map<String, dynamic>.from(
                                              stories[index]),
                                        )
                                      : _resultTypes.getHasMore()
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
