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
import 'package:voiceClient/services/mutation_service.dart';
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
  const FriendsPage({
    Key key,
    this.onPush,
  }) : super(key: key);
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

  VoidCallback _refetchQuery;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  dynamic allMyFriendRequests;
  dynamic allNewFriendRequestsToMe;

  Map<int, bool> moreSearchResults = {
    0: true,
    1: true,
  };

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

  Future<List<dynamic>> _getAllNewFriendRequestsToMe(
      BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final GraphQLClient graphQLClient =
        graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);

    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getAllNewFriendRequestsToMe),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    print(queryResult.data);
    return queryResult.data['User'][0]['messages']['from'];
  }

  Future<List<dynamic>> _getAllMyFriendRequests(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final GraphQLClient graphQLClient =
        graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getAllMyFriendRequests),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    return queryResult.data['User'][0]['messages']['to'];
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

  Future<void> _newFriendRequest(String _friendId) async {
    print('newFriendRequest');
    final bool addNewFriend = await PlatformAlertDialog(
      title: 'Request Friendship?',
      content: 'Are you sure?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Yes',
    ).show(context);
    if (addNewFriend == true) {
      final QueryResult result = await createUserMessage(
        GraphQLProvider.of(context).value,
        locator<GraphQLAuth>(),
        _friendId,
      );

      if (result.hasException) {
        throw result.exception;
      }

      allMyFriendRequests = await _getAllMyFriendRequests(context);
      allNewFriendRequestsToMe = await _getAllNewFriendRequestsToMe(context);

      _refetchQuery();
    } else {
      print('do not add friend');
    }
    return;
  }

  Future<void> _quitFriendRequest(String friendId) async {
    print('quitFriendRequest');
    final bool endFriendship = await PlatformAlertDialog(
      title: 'End Friendship?',
      content: 'Are you sure?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Yes',
    ).show(context);
    if (endFriendship == true) {
      final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

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

      allMyFriendRequests = await _getAllMyFriendRequests(context);
      allNewFriendRequestsToMe = await _getAllNewFriendRequestsToMe(context);
      _refetchQuery();
    } else {
      print('do not quit');
    }
  }

  Widget _build(BuildContext context) {
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
                  'offset': 0
                },
              ),
              builder: (
                QueryResult result, {
                VoidCallback refetch,
                FetchMore fetchMore,
              }) {
                _refetchQuery = refetch;
                if (result.loading && result.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (result.hasException) {
                  return Text('\nErrors: \n  ' + result.exception.toString());
                }

                final List<dynamic> friends =
                    result.data[searchResultsName[_typeUser.index]];

                //don't want to paginate the search results
                moreSearchResults[_typeUser.index] = false;

                final FetchMoreOptions opts = FetchMoreOptions(
                  variables: <String, dynamic>{'offset': friends.length},
                  updateQuery: (dynamic previousResultData,
                      dynamic fetchMoreResultData) {
                    // this is where you combine your previous data and response
                    // in this case, we want to display previous repos plus next repos
                    // so, we combine data in both into a single list of repos
                    final List<dynamic> repos = <dynamic>[
                      ...previousResultData[searchResultsName[_typeUser.index]],
                      ...fetchMoreResultData[
                          searchResultsName[_typeUser.index]],
                    ];

                    fetchMoreResultData[searchResultsName[_typeUser.index]] =
                        repos;

                    return fetchMoreResultData;
                  },
                );

                _scrollController
                  ..addListener(() {
                    if (_scrollController.position.pixels ==
                        _scrollController.position.maxScrollExtent) {
                      if (!result.loading &&
                          moreSearchResults[_typeUser.index]) {
                        fetchMore(opts);
                      }
                    }
                  });
                return _futures(context, friends);
              },
            )
          ],
        ),
      ),
    );
  }

  Expanded _expanded(List<dynamic> friends) {
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
              itemBuilder: (context, index) => StaggeredGridTileFriend(
                onPush: _typeUser == TypeUser.friends ? widget.onPush : null,
                friend: friends[index],
                friendButton: getFriendButton(
                  allNewFriendRequestsToMe,
                  allMyFriendRequests,
                  friends,
                  index,
                ),
              ),
              staggeredTileBuilder: (index) => StaggeredTile.fit(2),
            ),
    );
  }

  Widget _futures(BuildContext context, List<dynamic> friends) {
    return FutureBuilder(
      future: _getAllMyFriendRequests(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          allMyFriendRequests = snapshot.data;
          return FutureBuilder(
            future: _getAllNewFriendRequestsToMe(context),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                allNewFriendRequestsToMe = snapshot.data;
                return _expanded(friends);
              } else {
                return _progressIndicator();
              }
            },
          );
        } else {
          return _progressIndicator();
        }
      },
    );
  }

  FriendButton getFriendButton(
    dynamic allFriendRequestsToMe,
    dynamic allMyFriendRequests,
    dynamic friends,
    int index,
  ) {
    FriendButton button;
    if (_typeUser == TypeUser.friends) {
      button = FriendButton(
        key: Key('${Keys.newFriendsButton}-$index'),
        text: 'Quit Friend?',
        onPressed: () => _quitFriendRequest(friends[index]['id']),
      );
    } else {
      if (allMyFriendRequests != null) {
        for (var friend in allMyFriendRequests) {
          if (friend['User']['id'] == friends[index]['id']) {
            switch (friend['status']) {
              case 'reject':
                button = FriendButton(
                  key: Key('${Keys.newFriendsButton}-$index'),
                  text: "Rejected ${friend['resolved']['formatted']}",
                  onPressed: null,
                );
                break;
              case 'new':
                button = FriendButton(
                  key: Key('${Keys.newFriendsButton}-$index'),
                  text: 'Pending',
                  onPressed: null,
                );
                break;
              default:
            }
          }
        }
      }
      if (button == null) {
        if (allFriendRequestsToMe != null) {
          for (var friendRequestToMe in allFriendRequestsToMe) {
            if (friendRequestToMe['User']['id'] == friends[index]['id']) {
              button = FriendButton(
                key: Key('${Keys.newFriendsButton}-$index'),
                text: 'Pending',
                onPressed: null,
              );
            }
          }
        }
      }
      button ??= FriendButton(
        key: Key('${Keys.newFriendsButton}-$index'),
        text: 'New Friend?',
        onPressed: () => _newFriendRequest(friends[index]['id']),
      );
    }
    return button;
  }

  Widget _progressIndicator() {
    return SizedBox(
      width: 200.0,
      height: 300.0,
      child: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }
}
