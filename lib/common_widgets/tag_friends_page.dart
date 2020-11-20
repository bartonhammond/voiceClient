import 'package:MyFamilyVoice/common_widgets/staggered_grid_tile_tag.dart';
import 'package:MyFamilyVoice/common_widgets/tagged_friends.dart';
import 'package:MyFamilyVoice/services/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:MyFamilyVoice/app/sign_in/custom_raised_button.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/constants/strings.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/constants/mfv.i18n.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'package:MyFamilyVoice/services/logger.dart' as logger;

class TagFriendsPage extends StatefulWidget {
  const TagFriendsPage({
    Key key,
    this.story,
  }) : super(key: key);
  final Map<String, dynamic> story;
  @override
  _TagFriendsPageState createState() => _TagFriendsPageState();
}

class _TagFriendsPageState extends State<TagFriendsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nFriends = 20;
  int _skip = 0;

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
  };

  Map<int, String> searchResultsName = {
    0: 'userSearchFamily',
    1: 'userSearchFriends',
    2: 'userSearchNotFriends',
    3: 'User'
  };

  final List<Map<String, dynamic>> _tagItems = [];

  @override
  void initState() {
    _searchString = '*';
    _typeUser = TypeUser.family;
    super.initState();
  }

  @override
  void dispose() {
    _debouncer.stop();
    print('tags length: ${_tagItems.length}');
    super.dispose();
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
        ],
        onChanged: (value) {
          setState(() {
            _typeUser = value;
          });
        },
      ),
    );
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

  void onSelect(Map<String, dynamic> user) {
    setState(() {
      _tagItems.add(user);
    });
  }

  void onDelete(Map<String, dynamic> user) {
    for (var tag in _tagItems) {
      if (tag['id'] == user['id']) {
        _tagItems.remove(tag);
        setState(() {});
        return;
      }
    }
  }

  bool contains(Map<String, dynamic> user) {
    if (_tagItems.isEmpty) {
      return false;
    }
    for (var tag in _tagItems) {
      if (tag['id'] == user['id']) {
        return true;
      }
    }
    return false;
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