import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/app/sign_in/friend_button.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_friend.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/services/graphql_auth.dart';
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

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key key, this.onPush}) : super(key: key);
  final ValueChanged<String> onPush;

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final String title = 'My Family Voice';
  final nFriends = 20;
  final ScrollController _scrollController = ScrollController();
  String _searchString;
  final _debouncer = Debouncer(milliseconds: 500);
  TypeUser _typeUser;

  Map<int, String> searchResultsName = {
    0: 'userSearchFriends',
    1: 'userSearchNotFriends'
  };

  @override
  void initState() {
    _searchString = '*';
    _typeUser = TypeUser.friends;
    super.initState();
  }

  List<Widget> buildSearchField() {
    return <Widget>[
      Flexible(
        child: TextField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(15.0),
            hintText: 'Filter by name or home',
          ),
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
      )
    ];
  }

  List<Widget> buildTypeUserButtons() {
    return <Widget>[
      Flexible(
        child: RadioListTile<TypeUser>(
          title: const Text('Friends'),
          value: TypeUser.friends,
          groupValue: _typeUser,
          onChanged: (TypeUser value) {
            setState(() {
              _typeUser = value;
            });
          },
        ),
      ),
      Flexible(
        child: RadioListTile<TypeUser>(
          title: const Text('Users'),
          value: TypeUser.users,
          groupValue: _typeUser,
          onChanged: (TypeUser value) {
            setState(() {
              _typeUser = value;
              print('typeUser');
            });
          },
        ),
      ),
    ];
  }

  Future<void> _newFriendRequest(String friendId) async {
    print('newFriendRequest');
    return;
  }

  Future<void> _quitFriendRequest(String friendId) async {
    print('quitFriendRequest');
    final bool didRequestSignOut = await PlatformAlertDialog(
      title: 'Quit Friendship?',
      content: 'Are you sure?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Yes',
    ).show(context);
    if (didRequestSignOut == true) {
      final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
      final GraphQLClient graphQLClient =
          graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);

      MutationOptions options = MutationOptions(
        documentNode: gql(removeUserFriends),
        variables: <String, dynamic>{
          'from': graphQLAuth.getCurrentUserId(),
          'to': friendId,
        },
      );

      QueryResult result = await graphQLClient.mutate(options);

      if (result.hasException) {
        throw result.exception;
      }
      options = MutationOptions(
        documentNode: gql(removeUserFriends),
        variables: <String, dynamic>{
          'to': graphQLAuth.getCurrentUserId(),
          'from': friendId,
        },
      );

      result = await graphQLClient.mutate(options);
    } else {
      print('do not quit');
    }
  }

  @override
  Widget build(BuildContext context) {
    int offset = 0;
    bool shouldBeMore = true;
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    print('friendsPage build');
    return Scaffold(
        appBar: AppBar(
          backgroundColor: NeumorphicTheme.currentTheme(context).variantColor,
          title: Text(
            title,
            style: TextStyle(color: Colors.black),
          ),
        ),
        drawer: getDrawer(context),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildSearchField(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildTypeUserButtons(),
              ),
              Divider(),
              Query(
                  options: QueryOptions(
                    documentNode: _typeUser == TypeUser.friends
                        ? gql(userSearchFriends)
                        : gql(userSearchNotFriends),
                    variables: <String, dynamic>{
                      'searchString': _searchString,
                      'email': graphQLAuth.getUser().email,
                      'first': nFriends,
                      'offset': offset
                      // set cursor to null so as to start at the beginning
                      // 'cursor': 10
                    },
                  ),
                  builder: (QueryResult result,
                      {refetch, FetchMore fetchMore}) {
                    print('friendsPage queryResult: $result');
                    if (result.loading && result.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (result.hasException) {
                      return Text(
                          '\nErrors: \n  ' + result.exception.toString());
                    }

                    final List<dynamic> friends =
                        result.data[searchResultsName[_typeUser.index]];

                    if (result.data[searchResultsName[_typeUser.index]].length <
                        nFriends) {
                      shouldBeMore = false;
                    }
                    offset += nFriends;

                    final FetchMoreOptions opts = FetchMoreOptions(
                      variables: <String, dynamic>{'offset': offset},
                      updateQuery: (dynamic previousResultData,
                          dynamic fetchMoreResultData) {
                        // this is where you combine your previous data and response
                        // in this case, we want to display previous repos plus next repos
                        // so, we combine data in both into a single list of repos
                        final List<dynamic> repos = <dynamic>[
                          ...previousResultData[
                              searchResultsName[_typeUser.index]],
                          ...fetchMoreResultData[
                              searchResultsName[_typeUser.index]],
                        ];

                        fetchMoreResultData[
                            searchResultsName[_typeUser.index]] = repos;

                        return fetchMoreResultData;
                      },
                    );

                    _scrollController
                      ..addListener(() {
                        if (_scrollController.position.pixels ==
                            _scrollController.position.maxScrollExtent) {
                          if (!result.loading && shouldBeMore) {
                            fetchMore(opts);
                          }
                        }
                      });

                    return Expanded(
                      child: friends == null || friends.isEmpty
                          ? Text('No results')
                          : StaggeredGridView.countBuilder(
                              controller: _scrollController,
                              itemCount: friends.length,
                              primary: false,
                              crossAxisCount: 4,
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                              itemBuilder: (context, index) =>
                                  StaggeredGridTileFriend(
                                onPush: _typeUser == TypeUser.friends
                                    ? widget.onPush
                                    : null,
                                friend:
                                    Map<String, dynamic>.from(friends[index]),
                                friendButton: _typeUser == TypeUser.friends
                                    ? FriendButton(
                                        key: Key(
                                            '${Keys.newFriendsButton}-$index'),
                                        text: 'Quit Friend?',
                                        onPressed: () => _quitFriendRequest(
                                            friends[index]['id']),
                                      )
                                    : FriendButton(
                                        key: Key(
                                            '${Keys.newFriendsButton}-$index'),
                                        text: 'New  Friend?',
                                        onPressed: () => _newFriendRequest(
                                            friends[index]['id']),
                                      ),
                              ),
                              staggeredTileBuilder: (index) =>
                                  StaggeredTile.fit(2),
                            ),
                    );
                  })
            ],
          ),
        ));
  }
}
