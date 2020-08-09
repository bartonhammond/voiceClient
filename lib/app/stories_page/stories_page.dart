import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:voiceClient/app/sign_in/custom_raised_button.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_story.dart';

import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';

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

  @override
  void initState() {
    super.initState();
  }

  Map<bool, bool> moreSearchResults = {
    true: true,
    false: true,
  };

  Map<bool, String> resultType = <bool, String>{
    true: 'userFriendsStories',
    false: 'userStories'
  };

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

  Widget buildFriend(Map<String, dynamic> user) {
    return Card(
      child: Column(
        children: <Widget>[
          //new Center(child: new CircularProgressIndicator()),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: FadeInImage.memoryNetwork(
                  height: 75,
                  placeholder: kTransparentImage,
                  image: user['image'],
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
                ...previousResultData[resultType[getId() == null]],
                ...fetchMoreResultData[resultType[getId() == null]],
              ];

              fetchMoreResultData[resultType[getId() == null]] = data;

              return fetchMoreResultData;
            },
          );
          fetchMore(opts);
        });
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
        break;
      case DeviceScreenType.watch:
        _crossAxisCount = 1;
        break;
      default:
        _staggeredViewSize = 2;
        _crossAxisCount = 4;
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
                  Query(
                      options: getId() == null
                          ? QueryOptions(
                              documentNode: gql(getUserFriendsStories),
                              variables: <String, dynamic>{
                                'email': graphQLAuth.getUser().email,
                                'limit': nStories.toString(),
                                'cursor': DateTime.now().toIso8601String(),
                              },
                            )
                          : QueryOptions(
                              documentNode: gql(getUserStories),
                              variables: <String, dynamic>{
                                'email': user['email'],
                                'limit': nStories.toString(),
                                'cursor': DateTime.now().toIso8601String(),
                              },
                            ),
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
                            result.data[resultType[getId() == null]]);

                        if (stories.isEmpty || stories.length % nStories != 0) {
                          moreSearchResults[getId() == null] = false;
                        } else {
                          moreSearchResults[getId() == null] = true;
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
                                        : moreSearchResults[getId() == null]
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
