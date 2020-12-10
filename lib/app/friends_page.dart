import 'dart:async';

import 'package:MyFamilyVoice/services/debouncer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';

import 'package:MyFamilyVoice/app/sign_in/message_button.dart';
import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_friend.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/constants/keys.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;

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
  dynamic allMyFriends;

  int staggeredViewSize = 2;

  Map<int, bool> moreSearchResults = {
    0: true,
    1: true,
    2: true,
    3: true,
    4: true,
  };

  Map<int, String> searchResultsName = {
    0: 'userSearchFamily',
    1: 'userSearchFriends',
    2: 'userSearchNotFriends',
    3: 'userSearchBooks',
    4: 'User'
  };

  @override
  void initState() {
    _searchString = '*';
    _typeUser = TypeUser.family;
    super.initState();
  }

  @override
  void dispose() {
    _debouncer.stop();
    super.dispose();
  }

  Future<List> _getFriendsOfMineByEmail(BuildContext context) async {
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getFriendsOfMineQL),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;
    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    return queryResult.data['friendsOfMine'];
  }

  Future<List<dynamic>> _getAllNewFriendRequestsToMe(
      BuildContext context) async {
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;

    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getAllNewFriendRequestsToMe),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    return queryResult.data['User'][0]['messages']['from'];
  }

  Future<List<dynamic>> _getAllMyFriendRequests(BuildContext context) async {
    final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getAllMyFriendRequests),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
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
              Strings.typeUserButtonFamily.i18n,
            ),
            value: TypeUser.family,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonFriends.i18n,
            ),
            value: TypeUser.friends,
          ),
          DropdownMenuItem(
            child: Text('Books'),
            value: TypeUser.books,
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
      try {
        await addUserMessages(
          GraphQLProvider.of(context).value,
          graphQLAuth.getCurrentUserId(),
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
      } catch (e) {
        logger.createMessage(
            userEmail: graphQLAuth.getUser().email,
            source: 'friends_page',
            shortMessage: e.toString(),
            stackTrace: StackTrace.current.toString());
        rethrow;
      }
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

      final QueryResult result = await graphQLClient.mutate(options);

      if (result.hasException) {
        logger.createMessage(
            userEmail: graphQLAuth.getUser().email,
            source: 'friends_page',
            shortMessage: result.exception.toString(),
            stackTrace: StackTrace.current.toString());
        throw result.exception;
      }
      options = MutationOptions(
        documentNode: gql(removeUserFriends),
        variables: <String, dynamic>{
          'to': graphQLAuth.getCurrentUserId(),
          'from': friendId,
        },
      );

      await graphQLClient.mutate(options);

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
      case TypeUser.family:
        gqlString = userSearchFamilyQL;
        break;
      case TypeUser.friends:
        gqlString = userSearchFriendsQL;
        break;
      case TypeUser.users:
        gqlString = userSearchNotFriendsQL;
        break;
      case TypeUser.books:
        gqlString = userSearchBooksQL;
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
        _getFriendsOfMineByEmail(context),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.createMessage(
              userEmail: graphQLAuth.getUser().email,
              source: 'friends_page',
              shortMessage: snapshot.error.toString(),
              stackTrace: StackTrace.current.toString());

          return Text('\nErrors: \n  ' + snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return _progressIndicator();
        }
        allMyFriendRequests = snapshot.data[0];
        allNewFriendRequestsToMe = snapshot.data[1];
        allMyFriends = snapshot.data[2];
        return _build();
      },
    );
  }

  Widget _build() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00bcd4),
        title: Text(Strings.MFV.i18n),
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
                  logger.createMessage(
                      userEmail: graphQLAuth.getUser().email,
                      source: 'friends_page',
                      shortMessage: result.exception.toString(),
                      stackTrace: StackTrace.current.toString());
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
                                    typeUser: _typeUser,
                                    onPush: _typeUser == TypeUser.friends ||
                                            _typeUser == TypeUser.me ||
                                            _typeUser == TypeUser.family
                                        ? widget.onPush
                                        : null,
                                    friend: friends[index],
                                    friendButton: getMessageButton(
                                      allNewFriendRequestsToMe,
                                      allMyFriendRequests,
                                      allMyFriends,
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
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
      child: CustomRaisedButton(
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
        },
      ),
    );
  }

  MessageButton checkMyFriendRequests(
    dynamic allMyFriendRequests,
    dynamic friends,
    int index,
    double _fontSize,
  ) {
    //Are there friend requests to others
    if (allMyFriendRequests != null) {
      for (var friend in allMyFriendRequests) {
        if (friend['User']['id'] == friends[index]['id']) {
          switch (friend['status']) {
            case 'reject': //don't hurt feelings, ...
            case 'new':
              return MessageButton(
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
    return null;
  }

  MessageButton pendingFriendRequestsToMe(dynamic allFriendRequestsToMe,
      dynamic friends, int index, double _fontSize) {
    //Do I have pending friend requests?
    if (allFriendRequestsToMe != null) {
      for (var friendRequestToMe in allFriendRequestsToMe) {
        if (friendRequestToMe['User']['id'] == friends[index]['id']) {
          return MessageButton(
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
    return null;
  }

  MessageButton alreadyFriends(
    dynamic allMyFriends,
    dynamic friends,
    int index,
    double _fontSize,
  ) {
    if (allMyFriends != null) {
      for (var friendToMe in allMyFriends) {
        if (friendToMe['id'] == friends[index]['id']) {
          return MessageButton(
            key: Key('${Keys.newFriendsButton}-$index'),
            text: Strings.quitFriend.i18n,
            onPressed: () => _quitFriendRequest(friends[index]['id']),
            fontSize: _fontSize,
            icon: Icon(
              MdiIcons.accountRemove,
              color: Colors.white,
            ),
          );
        }
      }
    }
    return null;
  }

  Widget getMessageButton(
    dynamic allFriendRequestsToMe,
    dynamic allMyFriendRequests,
    dynamic allMyFriends,
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

    if (_typeUser == TypeUser.friends || _typeUser == TypeUser.family) {
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
      button =
          checkMyFriendRequests(allMyFriendRequests, friends, index, _fontSize);

      button ??= pendingFriendRequestsToMe(
          allFriendRequestsToMe, friends, index, _fontSize);

      button ??= alreadyFriends(allMyFriends, friends, index, _fontSize);

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
