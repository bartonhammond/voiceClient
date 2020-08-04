import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_story.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/constants/transparent_image.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({Key key, this.onPush, this.userId}) : super(key: key);
  final ValueChanged<String> onPush;
  final String userId;
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final String title = Strings.MFV;
  final nActivities = 20;
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

  Future<Map> getUserFromUserId() async {
    final Map<String, dynamic> user = <String, dynamic>{'empty': true};

    if (widget.userId == null) {
      return user;
    }
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getUserById),
      variables: <String, dynamic>{'id': widget.userId},
    );
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final GraphQLClient graphQLClient =
        graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);

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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          Text(
            user['home'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
          ),
          Text(
            user['birth'].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
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

  RaisedButton getButton(
    FetchMore fetchMore,
    List<dynamic> activities,
  ) {
    return RaisedButton(
        child: Text(Strings.loadMore),
        onPressed: () {
          final FetchMoreOptions opts = FetchMoreOptions(
            variables: <String, dynamic>{
              'cursor': getCursor(activities),
            },
            updateQuery:
                (dynamic previousResultData, dynamic fetchMoreResultData) {
              final List<dynamic> data = <dynamic>[
                ...previousResultData[resultType[widget.userId == null]],
                ...fetchMoreResultData[resultType[widget.userId == null]],
              ];

              fetchMoreResultData[resultType[widget.userId == null]] = data;

              return fetchMoreResultData;
            },
          );
          fetchMore(opts);
        });
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor:
                  NeumorphicTheme.currentTheme(context).variantColor,
              title: Text(
                title,
              ),
            ),
            drawer: widget.userId == null ? getDrawer(context) : null,
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  widget.userId == null ? Container() : buildFriend(user),
                  Query(
                      options: widget.userId == null
                          ? QueryOptions(
                              documentNode: gql(getUserFriendsStories),
                              variables: <String, dynamic>{
                                'email': graphQLAuth.getUser().email,
                                'limit': nActivities.toString(),
                                'cursor': DateTime.now().toIso8601String(),
                              },
                            )
                          : QueryOptions(
                              documentNode: gql(getUserStories),
                              variables: <String, dynamic>{
                                'email': user['email'],
                                'limit': nActivities.toString(),
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

                        final List<dynamic> activities = List<dynamic>.from(
                            result.data[resultType[widget.userId == null]]);

                        if (activities.isEmpty ||
                            activities.length % nActivities != 0) {
                          moreSearchResults[widget.userId == null] = false;
                        } else {
                          moreSearchResults[widget.userId == null] = true;
                        }

                        return Expanded(
                          child: activities == null || activities.isEmpty
                              ? Text(Strings.noResults)
                              : StaggeredGridView.countBuilder(
                                  controller: _scrollController,
                                  itemCount: activities.length + 1,
                                  primary: false,
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 4.0,
                                  crossAxisSpacing: 4.0,
                                  itemBuilder: (context, index) {
                                    return index < activities.length
                                        ? StaggeredGridTileStory(
                                            onPush: widget.onPush,
                                            showFriend: widget.userId == null,
                                            activity: Map<String, dynamic>.from(
                                                activities[index]),
                                          )
                                        : moreSearchResults[
                                                widget.userId == null]
                                            ? getButton(fetchMore, activities)
                                            : Container();
                                  },
                                  staggeredTileBuilder: (index) =>
                                      StaggeredTile.fit(2),
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
