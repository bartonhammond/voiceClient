import 'dart:async';
import 'package:MyFamilyVoice/constants/TmpObj.dart';
import 'package:MyFamilyVoice/ql/user/user_ban.dart';
import 'package:MyFamilyVoice/ql/user/user_search_me.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:MyFamilyVoice/ql/user/user_book_author.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_messages_received.dart';
import 'package:MyFamilyVoice/ql/user/user_search.dart';
import 'package:MyFamilyVoice/services/debouncer.dart';
import 'package:MyFamilyVoice/services/eventBus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/common_widgets/message_button.dart';
import 'package:MyFamilyVoice/common_widgets/drawer_widget.dart';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_friend.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
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
  StreamSubscription bookWasDeletedSubscription;
  StreamSubscription bookWasAddedSubscription;
  VoidCallback _refetchQuery;
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  final UserBookAuthor userBookAuthor = UserBookAuthor();
  final UserFriends userFriends = UserFriends();
  final UserMessagesReceived userMessagesReceived = UserMessagesReceived();
  final UserBan userBan = UserBan();
  UserQl userQl;

  int staggeredViewSize = 2;

  Map<int, bool> moreSearchResults = {
    0: true,
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
  };

  Map<int, String> searchResultsName = {
    0: 'userSearch',
    1: 'userSearchFamily',
    2: 'userSearchFriends',
    3: 'userSearchNotFriends',
    4: 'userSearchBooks',
    5: 'User'
  };

  @override
  void initState() {
    _searchString = '*';
    _typeUser = TypeUser.all;
    bookWasDeletedSubscription = eventBus.on<BookWasDeleted>().listen((event) {
      setState(() {
        _refetchQuery();
      });
    });
    bookWasAddedSubscription = eventBus.on<BookWasAdded>().listen((event) {
      setState(() {
        _refetchQuery();
      });
    });

    userQl = UserQl(
      userMessagesReceived: userMessagesReceived,
      userFriends: userFriends,
      userBookAuthor: userBookAuthor,
      userBan: userBan,
    );

    super.initState();
  }

  @override
  void dispose() {
    _debouncer.stop();
    bookWasDeletedSubscription.cancel();
    bookWasAddedSubscription.cancel();

    super.dispose();
  }

  Widget buildSearchField() {
    return Flexible(
      fit: FlexFit.loose,
      child: TextField(
        key: Key('searchField'),
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
              Strings.storiesPageAll.i18n,
              key: Key('usersPageAll'),
            ),
            value: TypeUser.all,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonFamily.i18n,
              key: Key('usersPageFamily'),
            ),
            value: TypeUser.family,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonFriends.i18n,
              key: Key('usersPageFriends'),
            ),
            value: TypeUser.friends,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonBooks.i18n,
              key: Key('usersPageBooks'),
            ),
            value: TypeUser.books,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonUsers.i18n,
              key: Key('usersPageUsers'),
            ),
            value: TypeUser.users,
          ),
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonMe.i18n,
              key: Key('usersPageMe'),
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

  Future<void> _newFriendRequest(Map<String, dynamic> toUser) async {
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
          graphQLClient: GraphQLProvider.of(context).value,
          fromUser: graphQLAuth.getUserMap(),
          toUser: toUser,
          messageId: _uuid.v1(),
          status: 'new',
          type: 'friend-request',
          key: null,
        );

        setState(() {
          _refetchQuery();
        });
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

  Future<void> _quitFriendRequest(Map<String, dynamic> friend) async {
    final bool endFriendship = await PlatformAlertDialog(
      title: Strings.cancelFriendship.i18n,
      content: Strings.areYouSure.i18n,
      cancelActionText: Strings.cancel.i18n,
      defaultActionText: Strings.yes.i18n,
    ).show(context);
    if (endFriendship == true) {
      final GraphQLClient graphQLClient = GraphQLProvider.of(context).value;
      await quitFriendship(
        graphQLClient,
        friendId1: friend['friendsTo'][0]['id'],
        friendId2: friend['friendsFrom'][0]['id'],
      );

      setState(() {
        _refetchQuery();
      });
    }
  }

  QueryOptions getQueryOptions() {
    _skip = 0;
    var _values = <String, dynamic>{
      'searchString': _searchString,
      'currentUserEmail': graphQLAuth.getUser().email,
      'limit': _nFriends.toString(),
      'skip': _skip.toString(),
    };
    final UserSearch userSearch = UserSearch.init(
      null,
      userQl,
      graphQLAuth.getUser().email,
    );
    switch (_typeUser) {
      case TypeUser.all:
        userSearch.setQueryName('userSearch');
        return userSearch.getQueryOptions(_values);
        break;
      case TypeUser.family:
        userSearch.setQueryName('userSearchFamily');
        return userSearch.getQueryOptions(_values);
        break;
      case TypeUser.friends:
        userSearch.setQueryName('userSearchFriends');
        return userSearch.getQueryOptions(_values);
        break;
      case TypeUser.users:
        userSearch.setQueryName('userSearchNotFriends');
        return userSearch.getQueryOptions(_values);
        break;
      case TypeUser.books:
        userSearch.setQueryName('userSearchBooks');
        return userSearch.getQueryOptions(_values);
        break;
      case TypeUser.me:
        _values = <String, dynamic>{
          'email': graphQLAuth.getUser().email,
        };
        return UserSearchMe.init(
          null,
          userQl,
          graphQLAuth.getUser().email,
        ).getQueryOptions(_values);
        break;

      default:
    }
    return null;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00bcd4),
        title: Text(Strings.MFV.i18n),
      ),
      drawer: DrawerWidget(),
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
                      ? Text(Strings.noResults.i18n, key: Key('noMessages'))
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
                                    onBanned: () {
                                      _refetchQuery();
                                    },
                                    typeUser: _typeUser,
                                    onPush: widget.onPush,
                                    friend: friends[index],
                                    friendButton: getMessageButton(
                                      friends[index],
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

  TmpObj checkMyFriendRequests(
    dynamic friend,
    double _fontSize,
  ) {
    if (friend['isBook']) {
      friend = friend['bookAuthor'];
    }
    //Are there friend requests to others
    if (friend['messagesReceived'] != null &&
        friend['messagesReceived'].length > 0) {
      for (var i = 0; i < friend['messagesReceived'].length; i++) {
        //pending message
        final dynamic message = friend['messagesReceived'][i];

        if (message['type'] == 'friend-request' &&
            message['status'] == 'new' &&
            message['sender']['email'] == graphQLAuth.getUser().email) {
          return TmpObj(
              button: MessageButton(
                key: Key('${Keys.newFriendsButton}-${friend["id"]}'),
                text: Strings.pending.i18n,
                onPressed: null,
                fontSize: _fontSize,
                icon: Icon(
                  MdiIcons.accountClockOutline,
                  color: Colors.white,
                ),
              ),
              isFriend: false,
              ignore: false);
        } //if
      } //for
    } //if
    return null;
  }

  TmpObj pendingFriendRequestsToMe(
    dynamic friend,
    double _fontSize,
  ) {
    String searchKey = 'messagesReceived';
    String fromToEmail = 'to';

    //Need to look at the message to the bookAuthor
    if (friend['isBook']) {
      searchKey = 'messagesReceived';
      fromToEmail = 'from';
    }
    if (friend[searchKey] != null && friend[searchKey].length > 0) {
      for (var i = 0; i < friend[searchKey].length; i++) {
        //pending message
        final dynamic message = friend[searchKey][i];

        if (message['type'] == 'friend-request' &&
            message['status'] == 'new' &&
            message[fromToEmail]['email'] == graphQLAuth.getUser().email) {
          return TmpObj(
              button: MessageButton(
                key: Key('${Keys.newFriendsButton}-${friend["id"]}'),
                text: Strings.pending.i18n,
                onPressed: null,
                fontSize: _fontSize,
                icon: Icon(
                  MdiIcons.accountClockOutline,
                  color: Colors.white,
                ),
              ),
              isFriend: false,
              ignore: false);
        }
      }
    }
    return null;
  }

  TmpObj alreadyFriends(
    dynamic friend,
    double _fontSize,
  ) {
    bool foundFriend = false;
    if (friend['friendsTo'].length > 0) {
      for (Map aFriend in friend['friendsTo']) {
        if (aFriend['receiver']['email'] == graphQLAuth.getUserMap()['email']) {
          foundFriend = true;
          break;
        }
      }
      if (foundFriend) {
        return TmpObj(
            button: MessageButton(
              key: Key('${Keys.newFriendsButton}-$friend["id"]'),
              text: Strings.quitFriend.i18n,
              onPressed: () => _quitFriendRequest(friend),
              fontSize: _fontSize,
              icon: Icon(
                MdiIcons.accountRemove,
                color: Colors.white,
              ),
            ),
            isFriend: true,
            ignore: false);
      }
    }
    return null;
  }

  TmpObj getMessageButton(dynamic friend) {
    if (friend['isBook'] &&
        friend['bookAuthor']['email'] == graphQLAuth.getUserMap()['email']) {
      return TmpObj(
        button: Container(),
        isFriend: true, //show that the family checkbox is not shown
        ignore: false,
      );
    }
    TmpObj button;
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
    if (_typeUser == TypeUser.me ||
        friend['id'] == graphQLAuth.getUserMap()['id']) {
      return TmpObj(
        button: Container(),
        isFriend: true,
        ignore: false,
      );
    }

    if (_typeUser == TypeUser.friends || _typeUser == TypeUser.family) {
      button = TmpObj(
          button: MessageButton(
            key: Key('${Keys.newFriendsButton}-${friend["id"]}'),
            text: Strings.quitFriend.i18n,
            onPressed: () => _quitFriendRequest(friend),
            fontSize: _fontSize,
            icon: Icon(
              MdiIcons.accountRemove,
              color: Colors.white,
            ),
          ),
          isFriend: true,
          ignore: false);
    } else {
      button = alreadyFriends(friend, _fontSize);

      //I have already sent a friend request to this person
      button ??= checkMyFriendRequests(friend, _fontSize);

      button ??= pendingFriendRequestsToMe(friend, _fontSize);

      button ??= TmpObj(
          button: MessageButton(
            key: Key('newFriendsButton-${friend["email"]}'),
            text: Strings.newFriend.i18n,
            onPressed: () => _newFriendRequest(friend),
            fontSize: _fontSize,
            icon: Icon(
              MdiIcons.accountPlusOutline,
              color: Colors.white,
            ),
          ),
          isFriend: false,
          ignore: false);
    }
    return button;
  }
}
