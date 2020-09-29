import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceClient/app/sign_in/custom_raised_button.dart';

import 'package:voiceClient/app/sign_in/message_button.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_friend.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/keys.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/mutation_service.dart';
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

  void stop() {
    _timer.cancel();
  }
}

class FriendsPage extends StatefulWidget {
  const FriendsPage({
    Key key,
    this.onPush,
  }) : super(key: key);
  final ValueChanged<Map<String, dynamic>> onPush;
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final String title = Strings.MFV.i18n;
  final _nFriends = 20;
  int _skip = 0;

  final ScrollController _scrollController = ScrollController();
  String _searchString;
  final _debouncer = Debouncer(milliseconds: 500);
  TypeUser _typeUser;

  VoidCallback _refetchQuery;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  dynamic allMyFriendRequests;
  dynamic allNewFriendRequestsToMe;
  int staggeredViewSize = 2;

  Map<int, bool> moreSearchResults = {
    0: true,
    1: true,
    2: true,
  };

  Map<int, String> searchResultsName = {
    0: 'userSearchFriends',
    1: 'userSearchNotFriends',
    2: 'User'
  };

  @override
  void initState() {
    _searchString = '*';
    _typeUser = TypeUser.friends;
    super.initState();
  }

  @override
  void dispose() {
    _debouncer.stop();
    super.dispose();
  }

  Future<List<dynamic>> _getAllNewFriendRequestsToMe(
      BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getAllNewFriendRequestsToMe),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      return null;
    }
    return queryResult.data['User'][0]['messages']['from'];
  }

  Future<List<dynamic>> _getAllMyFriendRequests(BuildContext context) async {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getAllMyFriendRequests),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      return null;
    }
    return queryResult.data['User'][0]['messages']['to'];
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

  Widget getDropDownTypeUserButtons() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<TypeUser>(
        value: _typeUser,
        items: [
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonFriends.i18n,
            ),
            value: TypeUser.friends,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonUsers.i18n,
            ),
            value: TypeUser.users,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonMe.i18n,
            ),
            value: TypeUser.me,
          ),
        ],
        onChanged: (value) {
          setState(() {
            _typeUser = value;
          });
        },
      ),
    );
  }

  Future<void> _newFriendRequest(String _friendId) async {
    final bool addNewFriend = await PlatformAlertDialog(
      title: Strings.requestFriendship.i18n,
      content: Strings.areYouSure.i18n,
      cancelActionText: Strings.cancel.i18n,
      defaultActionText: Strings.yes.i18n,
    ).show(context);
    if (addNewFriend == true) {
      final _uuid = Uuid();
      await addUserMessages(
        GraphQLProvider.of(context).value,
        locator<GraphQLAuth>().getCurrentUserId(),
        _friendId,
        _uuid.v1(),
        'new',
        'Friend Request',
        'friend-request',
        null,
      );

      allMyFriendRequests = await _getAllMyFriendRequests(context);
      allNewFriendRequestsToMe = await _getAllNewFriendRequestsToMe(context);

      _refetchQuery();
    }
    return;
  }

  Future<void> _quitFriendRequest(String friendId) async {
    final bool endFriendship = await PlatformAlertDialog(
      title: Strings.cancelFriendship.i18n,
      content: Strings.areYouSure.i18n,
      cancelActionText: Strings.cancel.i18n,
      defaultActionText: Strings.yes.i18n,
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
    }
  }

  QueryOptions getQueryOptions() {
    String gqlString;
    _skip = 0;
    var _variables = <String, dynamic>{
      'searchString': _searchString,
      'email': graphQLAuth.getUser().email,
      'limit': _nFriends.toString(),
      'skip': _skip.toString(),
    };
    switch (_typeUser) {
      case TypeUser.friends:
        gqlString = userSearchFriends;
        break;
      case TypeUser.users:
        gqlString = userSearchNotFriends;
        break;
      case TypeUser.me:
        gqlString = userSearchMeQL;
        _variables = <String, dynamic>{
          'email': graphQLAuth.getUser().email,
        };
        break;

      default:
    }
    return QueryOptions(
      documentNode: gql(gqlString),
      variables: _variables,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);

    switch (deviceType) {
      case DeviceScreenType.desktop:
      case DeviceScreenType.tablet:
        staggeredViewSize = 1;
        break;

      default:
        staggeredViewSize = 2;
    }
    return FutureBuilder(
      future: Future.wait([
        _getAllMyFriendRequests(context),
        _getAllNewFriendRequestsToMe(context),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          allMyFriendRequests = snapshot.data[0];
          allNewFriendRequestsToMe = snapshot.data[1];
          return _build();
        } else {
          return _progressIndicator();
        }
      },
    );
  }

  Widget _build() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00bcd4),
        title: Text(
          title.i18n,
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
              children: <Widget>[
                getDropDownTypeUserButtons(),
                buildSearchField(),
              ],
            ),
            Divider(),
            Query(
              options: getQueryOptions(),
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
                  return Text('\nErrors: \n  ' + result.exception.toString());
                }
                _refetchQuery = refetch;
                final List<dynamic> friends = List<dynamic>.from(
                    result.data[searchResultsName[_typeUser.index]]);

                if (friends.isEmpty || friends.length < _nFriends) {
                  moreSearchResults[_typeUser.index] = false;
                }

                return Expanded(
                  child: friends == null || friends.isEmpty
                      ? Text(Strings.noResults.i18n)
                      : StaggeredGridView.countBuilder(
                          controller: _scrollController,
                          itemCount: friends.length + 1,
                          primary: false,
                          crossAxisCount: 4,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          itemBuilder: (context, index) {
                            return index < friends.length
                                ? StaggeredGridTileFriend(
                                    onPush: _typeUser == TypeUser.friends ||
                                            _typeUser == TypeUser.me
                                        ? widget.onPush
                                        : null,
                                    friend: friends[index],
                                    friendButton: getMessageButton(
                                      allNewFriendRequestsToMe,
                                      allMyFriendRequests,
                                      friends,
                                      index,
                                    ),
                                  )
                                : moreSearchResults[_typeUser.index]
                                    ? getLoadMoreButton(fetchMore, friends)
                                    : Container();
                          },
                          staggeredTileBuilder: (index) =>
                              StaggeredTile.fit(staggeredViewSize),
                        ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void isThereMoreSearchResults(dynamic fetchMoreResultData) {
    moreSearchResults[_typeUser.index] =
        fetchMoreResultData[searchResultsName[_typeUser.index]].length > 0;
  }

  Widget getLoadMoreButton(
    FetchMore fetchMore,
    List<dynamic> friends,
  ) {
    return CustomRaisedButton(
        text: Strings.loadMore.i18n,
        icon: Icon(
          Icons.arrow_downward,
          color: Colors.white,
        ),
        onPressed: () {
          _skip += _nFriends;
          final FetchMoreOptions opts = FetchMoreOptions(
            variables: <String, dynamic>{
              'skip': _skip.toString(),
            },
            updateQuery:
                (dynamic previousResultData, dynamic fetchMoreResultData) {
              final List<dynamic> data = <dynamic>[
                ...previousResultData[searchResultsName[_typeUser.index]],
                ...fetchMoreResultData[searchResultsName[_typeUser.index]],
              ];
              isThereMoreSearchResults(fetchMoreResultData);
              fetchMoreResultData[searchResultsName[_typeUser.index]] = data;
              return fetchMoreResultData;
            },
          );
          fetchMore(opts);
        });
  }

  Widget getMessageButton(
    dynamic allFriendRequestsToMe,
    dynamic allMyFriendRequests,
    dynamic friends,
    int index,
  ) {
    MessageButton button;
    final DeviceScreenType deviceType =
        getDeviceType(MediaQuery.of(context).size);
    double _fontSize = 20;
    switch (deviceType) {
      case DeviceScreenType.watch:
        _fontSize = 12;
        break;
      default:
        _fontSize = 20;
    }
    if (_typeUser == TypeUser.me) {
      return Container();
    }
    if (_typeUser == TypeUser.friends) {
      button = MessageButton(
        key: Key('${Keys.newFriendsButton}-$index'),
        text: Strings.quitFriend.i18n,
        onPressed: () => _quitFriendRequest(friends[index]['id']),
        fontSize: _fontSize,
        icon: Icon(
          MdiIcons.accountRemove,
          color: Colors.white,
        ),
      );
    } else {
      if (allMyFriendRequests != null) {
        for (var friend in allMyFriendRequests) {
          if (friend['User']['id'] == friends[index]['id']) {
            switch (friend['status']) {
              case 'reject':
                button = MessageButton(
                  key: Key('${Keys.newFriendsButton}-$index'),
                  text: Strings.pending.i18n,
                  onPressed: null,
                  fontSize: _fontSize,
                  icon: Icon(
                    MdiIcons.accountClockOutline,
                    color: Colors.white,
                  ),
                );
                break;
              case 'new':
                button = MessageButton(
                  key: Key('${Keys.newFriendsButton}-$index'),
                  text: Strings.pending.i18n,
                  onPressed: null,
                  fontSize: _fontSize,
                  icon: Icon(
                    MdiIcons.accountClockOutline,
                    color: Colors.white,
                  ),
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
              button = MessageButton(
                key: Key('${Keys.newFriendsButton}-$index'),
                text: Strings.pending.i18n,
                onPressed: null,
                fontSize: _fontSize,
                icon: Icon(
                  MdiIcons.accountClockOutline,
                  color: Colors.white,
                ),
              );
            }
          }
        }
      }
      button ??= MessageButton(
        key: Key('${Keys.newFriendsButton}-$index'),
        text: Strings.newFriend.i18n,
        onPressed: () => _newFriendRequest(friends[index]['id']),
        fontSize: _fontSize,
        icon: Icon(
          MdiIcons.accountPlusOutline,
          color: Colors.white,
        ),
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
}
