import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_story.dart';
import 'package:voiceClient/constants/enums.dart';

import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/host.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';

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
    final Map<String, dynamic> user = <String, dynamic>{'empty': true};

    if (widget.params == null || getId() == null) {
      return user;
    }
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getUserById),
      variables: <String, dynamic>{'id': getId()},
    );

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
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
            hintText: Strings.filterText.i18n,
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

  Widget buildFriend(Map<String, dynamic> user) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    int _width = 100;
    int _height = 200;
    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        _width = _height = 50;
        break;
      case DeviceScreenType.watch:
        _width = _height = 50;
        break;
      case DeviceScreenType.mobile:
        _width = _height = 50;
        break;
      default:
        _width = _height = 100;
    }
    return Card(
      child: Column(
        children: <Widget>[
          //new Center(child: new CircularProgressIndicator()),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: FadeInImage.memoryNetwork(
                height: _height.toDouble(),
                width: _width.toDouble(),
                placeholder: kTransparentImage,
                image: host(
                  user['image'],
                  width: _width,
                  height: _height,
                  resizingType: 'fill',
                  enlarge: 1,
                ),
              ),
            ),
          ),
          Text(
            user['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            user['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          Text(
            user['birth'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          )
        ],
      ),
    );
  }

  String getCursor(List<dynamic> _list) {
    String datetime;
    if (_list == null || _list.isEmpty) {
      datetime = DateTime.now().toIso8601String();
    } else {
      datetime = _list[_list.length - 1]['created']['formatted'];
    }
    return datetime;
  }

  Widget getButton(
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
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
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
                  getId() == null ? Container() : buildFriend(user),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      getDropDownTypeSearchButtons(),
                      buildSearchField(),
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
                          return Text(
                              '\nErrors: \n  ' + result.exception.toString());
                        }

                        final List<dynamic> stories = List<dynamic>.from(
                            result.data[_resultTypes.getResultType()]);

                        if (stories.isEmpty || stories.length % nStories != 0) {
                          _resultTypes.setHasMore(false);
                        } else {
                          _resultTypes.setHasMore(true);
                        }

                        return Expanded(
                          child: stories == null || stories.isEmpty
                              ? Text(Strings.noResults.i18n)
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
                                            story: Map<String, dynamic>.from(
                                                stories[index]),
                                          )
                                        : _resultTypes.getHasMore()
                                            ? getButton(fetchMore, stories)
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
        }
      },
    );
  }
}