import 'dart:async';
import 'package:MyFamilyVoice/common_widgets/platform_alert_dialog.dart';
import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_tag.dart';
import 'package:MyFamilyVoice/common_widgets/tagged_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_book_author.dart';
import 'package:MyFamilyVoice/ql/user/user_friends.dart';
import 'package:MyFamilyVoice/ql/user/user_messages_received.dart';
import 'package:MyFamilyVoice/ql/user/user_search.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:MyFamilyVoice/services/debouncer.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;

class TagFriendsPage extends StatefulWidget {
  const TagFriendsPage({
    Key key,
    this.story,
    this.onSaved,
    this.isBook = false,
    this.onBookSave,
  }) : super(key: key);
  final Map<String, dynamic> story;
  final VoidCallback onSaved;
  final bool isBook;

  final Future<void> Function(String) onBookSave;
  @override
  _TagFriendsPageState createState() => _TagFriendsPageState();
}

class _TagFriendsPageState extends State<TagFriendsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nFriends = 20;
  int _skip = 0;
  bool _tagsHaveChanged = false;

  final UserBookAuthor userBookAuthor = UserBookAuthor();
  final UserFriends userFriends = UserFriends();
  final UserMessagesReceived userMessagesReceived =
      UserMessagesReceived(useFilter: true);
  UserQl userQl;

  final ScrollController _scrollController = ScrollController();
  String _searchString;
  final _debouncer = Debouncer(milliseconds: 500);
  TypeUser _typeUser;

  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

  dynamic allMyFriendRequests;
  dynamic allNewFriendRequestsToMe;
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
    0: 'userSearch', //TypeUser.all
    1: 'userSearchFamily', //TypeUser.family
    2: 'userSearchFriends', //TypeUser.friends
    3: 'userSearchNotFriends', //TypeUser.users
    4: 'userSearchBooks', //TypeUser.books
    5: 'User' //TypeUser.me
  };

  Map<int, String> searchResultsNameBooks = {
    0: 'userSearchBooks',
    1: 'userSearchFamilyBooks',
    2: 'userSearchFriendsBooks',
    3: 'userSearchNotFriendsBooks',
    4: 'userSearchBooks',
    5: 'User'
  };

  final List<Map<String, dynamic>> _tagItems = [];

  @override
  void initState() {
    _searchString = '*';
    _typeUser = TypeUser.family;
    if (widget.story != null) {
      if (widget.story['type'] == 'FRIENDS') {
        _typeUser = TypeUser.friends;
      }
      if (!widget.isBook) {
        widget.story['tags'].forEach((dynamic tag) => _tagItems.add(tag));
      } else {
        if (widget.story['user']['isBook']) {
          final tag = <String, dynamic>{
            'id': '',
            'user': widget.story['user'],
          };
          _tagItems.add(tag);
        }
      }
    }
    userQl = UserQl(
      userMessagesReceived: userMessagesReceived,
      userFriends: userFriends,
      userBookAuthor: userBookAuthor,
    );

    super.initState();
  }

  @override
  void dispose() {
    _debouncer.stop();
    super.dispose();
  }

  Widget buildSearchField() {
    return Flexible(
      fit: FlexFit.loose,
      child: TextField(
        key: Key('tagFriendsPageSearch'),
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

  List<DropdownMenuItem<TypeUser>> getDropDownButtons() {
    final items = <DropdownMenuItem<TypeUser>>[];
    if (widget.isBook) {
      items.add(DropdownMenuItem(
        child: Text(
          Strings.typeUserButtonFamily.i18n,
        ),
        value: TypeUser.family,
      ));
      items.add(DropdownMenuItem(
        child: Text(
          Strings.typeUserButtonFriends.i18n,
        ),
        value: TypeUser.friends,
      ));
    } else {
      items.add(DropdownMenuItem(
        child: Text(
          Strings.typeUserButtonFamily.i18n,
        ),
        value: TypeUser.family,
      ));
      if (widget.story['type'] == 'FRIENDS') {
        items.add(
          DropdownMenuItem(
            child: Text(
              Strings.typeUserButtonFriends.i18n,
            ),
            value: TypeUser.friends,
          ),
        );
      }
    }
    return items;
  }

  Widget getDropDownTypeUserButtons() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<TypeUser>(
        value: _typeUser,
        items: getDropDownButtons(),
        onChanged: (value) {
          setState(() {
            _typeUser = value;
          });
        },
      ),
    );
  }

  QueryOptions getQueryOptions() {
    _skip = 0;
    final _variables = <String, dynamic>{
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
      case TypeUser.family:
        if (widget.isBook) {
          userSearch.setQueryName('userSearchFamilyBooks');
          return userSearch.getQueryOptions(_variables);
        } else {
          userSearch.setQueryName('userSearchFamily');
          return userSearch.getQueryOptions(_variables);
        }
        break;
      case TypeUser.friends:
        if (widget.isBook) {
          //Only books who are friends
          userSearch.setQueryName('userSearchFriendsBooks');
          return userSearch.getQueryOptions(_variables);
        } else {
          userSearch.setQueryName('userSearchFriends');
          return userSearch.getQueryOptions(_variables);
        }
        break;
      case TypeUser.users:
        if (widget.isBook) {
          userSearch.setQueryName('userSearchNotFriendsBooks');
          return userSearch.getQueryOptions(_variables);
        } else {
          userSearch.setQueryName('userSearchNotFriends');
          return userSearch.getQueryOptions(_variables);
        }
        break;
      case TypeUser.books:
        userSearch.setQueryName('userSearchBooks');
        return userSearch.getQueryOptions(_variables);
        break;
      case TypeUser.me:
        userSearch.setQueryName('User');
        return userSearch.getQueryOptions(_variables);
        break;

      default:
    }
    return null;
  }

  bool haveTagsChanged() {
    if (_tagItems.length != widget.story['tags'].length) {
      return true;
    }
    //Are all the tags already in the story
    for (var tag in _tagItems) {
      for (var storyTag in widget.story['tags']) {
        if (tag['user']['id'] == storyTag['user']['id']) {
          break;
        }
        return true;
      }
    }

    for (var storyTag in widget.story['tags']) {
      for (var tag in _tagItems) {
        if (tag['user']['id'] == storyTag['user']['id']) {
          break;
        }
        return true;
      }
    }
    return false;
  }

  Future<void> onSelect(Map<String, dynamic> user) async {
    if (widget.isBook && _tagItems.length == 1) {
      await PlatformAlertDialog(
        title: Strings.selectBookTitle.i18n,
        content: Strings.selectBookDescription.i18n,
        defaultActionText: Strings.ok.i18n,
      ).show(context);
      return;
    }
    final dynamic tag = {
      'id': '',
      'user': user,
    };
    _tagItems.add(tag);
    if (widget.story == null || widget.isBook) {
      _tagsHaveChanged = true;
    } else {
      _tagsHaveChanged = haveTagsChanged();
    }

    setState(() {});
  }

  void onDelete(Map<String, dynamic> user) {
    _tagsHaveChanged = false;
    for (var tag in _tagItems) {
      if (tag['id'] == user['id']) {
        _tagItems.remove(tag);
        break;
      }
    }
    setState(() {
      if (widget.isBook &&
          widget.story['user']['isBook'] &&
          _tagItems.isEmpty) {
        _tagsHaveChanged = true;
      } else {
        _tagsHaveChanged = haveTagsChanged();
      }
    });
  }

  bool contains(Map<String, dynamic> user) {
    if (_tagItems.isEmpty) {
      return false;
    }
    for (var tag in _tagItems) {
      if (tag['user']['id'] == user['id']) {
        return true;
      }
    }
    return false;
  }

  Widget getSaveButton({bool showIcon = true}) {
    return CustomRaisedButton(
      key: Key('tagFreindsPageSave'),
      text: 'Save',
      icon: showIcon
          ? Icon(
              Icons.save,
              color: Colors.white,
            )
          : null,
      onPressed: _tagsHaveChanged
          ? () async {
              if (widget.isBook) {
                if (widget.onBookSave != null) {
                  //assign to book
                  if (_tagItems.length == 1) {
                    await widget.onBookSave(_tagItems[0]['user']['id']);
                    setState(() {
                      _tagsHaveChanged = false;
                    });
                    Navigator.pop(context);
                  } else {
                    //remove current book
                    await widget.onBookSave(null);
                    setState(() {
                      _tagsHaveChanged = false;
                    });
                  }
                }
              } else {
                await deleteStoryTags(
                  GraphQLProvider.of(context).value,
                  widget.story['id'],
                );
                for (var tag in _tagItems) {
                  await addStoryTag(
                    graphQLAuth.getUserMap(),
                    GraphQLProvider.of(context).value,
                    widget.story,
                    tag,
                  );
                }
                //Sync up so differences can be tested
                widget.story['tags'] = <Map<String, dynamic>>[];
                // ignore: avoid_function_literals_in_foreach_calls
                _tagItems.forEach((tag) {
                  widget.story['tags'].add(tag);
                });
                setState(() {
                  _tagsHaveChanged = false;
                });
                if (widget.onSaved != null) {
                  widget.onSaved();
                }
                Navigator.pop(context);
              }
            }
          : null,
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

    return WillPopScope(
      onWillPop: () async {
        if (_tagsHaveChanged) {
          final bool saveChanges = await PlatformAlertDialog(
                  title: 'There are pending changes',
                  content: 'Stay on page to save changes?',
                  cancelActionText: 'No',
                  defaultActionText: 'Stay')
              .show(context);
          if (saveChanges == true) {
            return false;
          }
          return true;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xff00bcd4),
          title: Text(Strings.MFV.i18n),
        ),
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
                  getSaveButton(),
                ],
              ),
              Divider(),
              TaggedFriends(
                key: Key('tagFriendsKey'),
                items: _tagItems,
                onDelete: onDelete,
              ),
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

                  List<dynamic> friends;
                  if (widget.isBook) {
                    friends = List<dynamic>.from(
                        result.data[searchResultsNameBooks[_typeUser.index]]);
                  } else {
                    friends = List<dynamic>.from(
                        result.data[searchResultsName[_typeUser.index]]);
                  }
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
                            crossAxisCount: 1,
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 4.0,
                            itemBuilder: (context, index) {
                              return index < friends.length
                                  ? contains(friends[index])
                                      ? Container()
                                      : StaggeredGridTileTag(
                                          typeUser: _typeUser,
                                          friend: friends[index],
                                          onSelect: onSelect,
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
}
