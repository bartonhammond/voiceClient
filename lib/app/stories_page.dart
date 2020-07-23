import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/common_widgets/drawer_widget.dart';
import 'package:voiceClient/common_widgets/staggered_grid_tile_story.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
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
  final String title = 'My Family Voice';
  final nActivities = 20;
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> user;
  @override
  void initState() {
    super.initState();
  }

  Map<bool, String> resultType = <bool, String>{
    true: 'activities',
    false: 'stories'
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

  @override
  Widget build(BuildContext context) {
    bool shouldBeMore = true;
    int offset = 0;
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
          print('storiesPage build');
          user = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              backgroundColor:
                  NeumorphicTheme.currentTheme(context).variantColor,
              title: Text(
                title,
                style: TextStyle(color: Colors.black),
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
                              documentNode: gql(userActivities),
                              variables: <String, dynamic>{
                                'email': graphQLAuth.getUser().email,
                                'first': nActivities,
                                'offset': offset
                                // set cursor to null so as to start at the beginning
                                // 'cursor': 10
                              },
                            )
                          : QueryOptions(
                              documentNode: gql(userStories),
                              variables: <String, dynamic>{
                                'email': user['email'],
                                'first': nActivities,
                                'offset': offset
                                // set cursor to null so as to start at the beginning
                                // 'cursor': 10
                              },
                            ),
                      builder: (QueryResult result,
                          {refetch, FetchMore fetchMore}) {
                        print('homePage queryResult: $result');
                        if (result.loading && result.data == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (result.hasException) {
                          return Text(
                              '\nErrors: \n  ' + result.exception.toString());
                        }

                        final List<dynamic> activities = result.data['User'][0]
                            [resultType[widget.userId == null]];

                        if (result.data['User'][0].length < nActivities) {
                          shouldBeMore = false;
                        }
                        offset += nActivities;

                        final FetchMoreOptions opts = FetchMoreOptions(
                          variables: <String, dynamic>{'offset': offset},
                          updateQuery: (dynamic previousResultData,
                              dynamic fetchMoreResultData) {
                            // this is where you combine your previous data and response
                            // in this case, we want to display previous repos plus next repos
                            // so, we combine data in both into a single list of repos
                            final List<dynamic> repos = <dynamic>[
                              ...previousResultData['User'][0]
                                  [widget.userId == null],
                              ...fetchMoreResultData['User'][0]
                                  [widget.userId == null],
                            ];

                            fetchMoreResultData['User'][0]
                                [widget.userId == null] = repos;

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
                          child: StaggeredGridView.countBuilder(
                            controller: _scrollController,
                            itemCount: activities.length,
                            primary: false,
                            crossAxisCount: 4,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            itemBuilder: (context, index) =>
                                StaggeredGridTileStory(
                              onPush: widget.onPush,
                              showFriend: widget.userId == null,
                              activity:
                                  Map<String, dynamic>.from(activities[index]),
                            ),
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
